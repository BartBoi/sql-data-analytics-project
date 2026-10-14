
--Show monthly total sales, the number of unique customers, and the total units sold in that month.

SELECT
DATETRUNC(month, order_date) AS order_month,
SUM(sales) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);
