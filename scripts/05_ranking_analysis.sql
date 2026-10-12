
--Which 5 products generate the highest revenue?
SELECT TOP 5
p.product_name,
SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC, p.product_name ASC;


--What are the 5 worst performing products in terms of sales?
SELECT * FROM (
    SELECT
    p.product_name,
    SUM(s.sales) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(s.sales) ASC, p.product_name ASC) AS rank
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    GROUP BY p.product_name
)t
WHERE rank <= 5
ORDER BY rank ASC;

--Find the top 10 customers who have generated the highest revenue.
SELECT * FROM (
    SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(s.sales) AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(s.sales) DESC, c.customer_key ASC) AS rank
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
    GROUP BY c.customer_key, c.first_name, c.last_name
)t
WHERE rank <= 10
ORDER BY rank ASC;

--Find the 3 customers with the fewest orders placed.
SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders ASC, c.customer_key ASC;
