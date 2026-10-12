
--Which categories contribute the most to the overall sales?
WITH category_sales AS (
SELECT
category,
SUM(sales) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key
GROUP BY category)

SELECT
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
