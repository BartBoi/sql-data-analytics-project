
--Calculate the running total sales per month
--and the running total of sales over time.

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date ASC) AS running_total_sales,
AVG(average_price) OVER (ORDER BY order_date ASC) AS moving_average_price
FROM (
    SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales) AS total_sales,
    AVG(CAST(price AS DECIMAL(18, 2))) AS average_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
)t
ORDER BY order_date ASC;
