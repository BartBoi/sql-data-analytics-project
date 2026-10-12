
/*
==============================================================================================
Product Report
==============================================================================================
Purpose:
    -This report consolidates key product metrics and patterns.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Performers, Low-Performers.
    3. Aggregates product-level metrics:
        -total orders
        -total sales
        -total quantity sold
        -total customers (unique)
        -lifespan (in months)
    4.Calculates valuable KPIs:
        -recency (months since last sale)
        -average order revenue (AOR)
        -average monthly revenue
==============================================================================================
*/

CREATE OR ALTER VIEW gold.report_products AS
WITH base_query AS(
/*---------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------------------------*/
SELECT
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost,
s.order_date,
s.sales,
s.quantity,
s.order_number,
s.customer_key
FROM gold.dim_products p
LEFT JOIN gold.fact_sales s
ON p.product_key = s.product_key
WHERE order_date IS NOT NULL
)

,product_aggregations AS(
/*---------------------------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------------------------*/
SELECT
product_key,
product_name,
category,
subcategory,
cost,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
MAX(order_date) AS last_sale_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key,
    product_name,
    category,
    subcategory,
    cost
)

/*---------------------------------------------------------------------------------------------
3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------------------------*/

SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
CASE
    WHEN total_sales > 50000 THEN 'High-Performer'
    WHEN total_sales >= 10000 THEN 'Medium-Performer'
    ELSE 'Low-Performer'
END product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
--Average Order Revenue (AOR)
CASE
    WHEN total_orders = 0 THEN 0
    ELSE ROUND(CAST(total_sales AS DECIMAL(18, 2)) / total_orders, 2)
END avg_order_rev,
--Average Monthly Revenue
CASE
    WHEN lifespan = 0 THEN total_sales
    ELSE ROUND(CAST(total_sales AS DECIMAL(18, 2)) / lifespan, 2)
END avg_monthly_rev
FROM product_aggregations;
