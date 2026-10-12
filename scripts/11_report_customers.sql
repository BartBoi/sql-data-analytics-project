
/*
==============================================================================================
Customer Report
==============================================================================================
Purpose:
    -This report consolidates key customer metrics and behaviours

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        -total orders
        -total sales
        -total quantity purchased
        -total products
        -lifespan (in months)
    4.Calculates valuable KPIs:
        -recency (months since last order)
        -average order value
        -average monthly spend
==============================================================================================
*/

CREATE OR ALTER VIEW gold.report_customers AS
WITH base_query AS(
/*---------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------------------------*/
SELECT
s.order_number,
s.product_key,
s.order_date,
s.sales,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ' ,c.last_name) AS customer_name,
DATEDIFF(year, c.birth_date, GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
/*---------------------------------------------------------------------------------------------
2) Customer Aggregations: Summarises at the customer level
---------------------------------------------------------------------------------------------*/
SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key,
        customer_number,
        customer_name,
        age)


/*---------------------------------------------------------------------------------------------
3) Final Query: Combines all customer results into one output
---------------------------------------------------------------------------------------------*/

SELECT
customer_key,
customer_number,
customer_name,
age,
CASE
    WHEN age IS NULL THEN 'Unknown'
    WHEN age <20 THEN 'Under 20'
    WHEN age BETWEEN 20 AND 29 THEN '20-29'
    WHEN age BETWEEN 30 AND 39 THEN '30-39'
    WHEN age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50 and above'
END age_group,
CASE
    WHEN lifespan >=12 AND total_sales > 5000 THEN 'VIP'
    WHEN lifespan >=12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END customer_segment,
DATEDIFF(month, last_order_date, GETDATE()) AS recency_in_months,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
--Compute average order value (AOV)-------------------------------------
CASE WHEN total_orders = 0 THEN 0
    ELSE ROUND(CAST(total_sales AS DECIMAL(18, 2)) / total_orders, 2)
END AS avg_order_value,
--Compute average monthly spend-----------------------------------------
CASE WHEN lifespan = 0 THEN total_sales
    ELSE ROUND(CAST(total_sales AS DECIMAL(18, 2)) / lifespan, 2)
END AS avg_monthly_spend
FROM customer_aggregation;
