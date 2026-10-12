/*
Report Quality Checks

Created by ChatGPT to help confirm the functionality of the customer and product
report scripts. These checks were not covered in Data With Baraa's course and
were added as an extra validation step.

The checks compare the report views with source sales that have a valid order
date. No data is changed.
*/
SET NOCOUNT ON;

IF OBJECT_ID('gold.report_customers', 'V') IS NULL
    THROW 51000, 'Create gold.report_customers before running these checks.', 1;
IF OBJECT_ID('gold.report_products', 'V') IS NULL
    THROW 51000, 'Create gold.report_products before running these checks.', 1;

IF EXISTS (SELECT customer_key FROM gold.report_customers
           GROUP BY customer_key HAVING COUNT(*) > 1)
    THROW 51000, 'Duplicate customer report keys.', 1;
IF EXISTS (SELECT product_key FROM gold.report_products
           GROUP BY product_key HAVING COUNT(*) > 1)
    THROW 51000, 'Duplicate product report keys.', 1;

DECLARE @sales BIGINT, @quantity BIGINT;
SELECT @sales = SUM(CAST(sales AS BIGINT)),
       @quantity = SUM(CAST(quantity AS BIGINT))
FROM gold.fact_sales WHERE order_date IS NOT NULL;

IF COALESCE((SELECT SUM(CAST(total_sales AS BIGINT)) FROM gold.report_customers), 0)
   <> COALESCE(@sales, 0)
    THROW 51000, 'Customer report sales do not reconcile.', 1;
IF COALESCE((SELECT SUM(CAST(total_sales AS BIGINT)) FROM gold.report_products), 0)
   <> COALESCE(@sales, 0)
    THROW 51000, 'Product report sales do not reconcile.', 1;
IF COALESCE((SELECT SUM(CAST(total_quantity AS BIGINT)) FROM gold.report_customers), 0)
   <> COALESCE(@quantity, 0)
    THROW 51000, 'Customer report quantities do not reconcile.', 1;
IF COALESCE((SELECT SUM(CAST(total_quantity AS BIGINT)) FROM gold.report_products), 0)
   <> COALESCE(@quantity, 0)
    THROW 51000, 'Product report quantities do not reconcile.', 1;

IF EXISTS (
    SELECT customer_key, COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales WHERE order_date IS NOT NULL GROUP BY customer_key
    EXCEPT SELECT customer_key, total_orders FROM gold.report_customers
) OR EXISTS (
    SELECT customer_key, total_orders FROM gold.report_customers
    EXCEPT SELECT customer_key, COUNT(DISTINCT order_number)
    FROM gold.fact_sales WHERE order_date IS NOT NULL GROUP BY customer_key
)
    THROW 51000, 'Customer report order counts do not reconcile.', 1;

IF EXISTS (
    SELECT product_key, COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales WHERE order_date IS NOT NULL GROUP BY product_key
    EXCEPT SELECT product_key, total_orders FROM gold.report_products
) OR EXISTS (
    SELECT product_key, total_orders FROM gold.report_products
    EXCEPT SELECT product_key, COUNT(DISTINCT order_number)
    FROM gold.fact_sales WHERE order_date IS NOT NULL GROUP BY product_key
)
    THROW 51000, 'Product report order counts do not reconcile.', 1;

IF EXISTS (SELECT 1 FROM gold.report_customers
           WHERE age IS NULL AND age_group <> 'Unknown')
    THROW 51000, 'Missing ages must have an Unknown age group.', 1;
IF EXISTS (SELECT 1 FROM gold.report_customers
           WHERE lifespan >= 12 AND total_sales = 5000 AND customer_segment <> 'Regular')
    THROW 51000, 'The 5000 boundary must be Regular.', 1;

SELECT 'Customers' AS report, COUNT(*) AS report_rows,
       SUM(CAST(total_sales AS BIGINT)) AS total_sales,
       SUM(CAST(total_quantity AS BIGINT)) AS total_quantity
FROM gold.report_customers
UNION ALL
SELECT 'Products', COUNT(*), SUM(CAST(total_sales AS BIGINT)),
       SUM(CAST(total_quantity AS BIGINT))
FROM gold.report_products;

PRINT 'All report checks passed.';
