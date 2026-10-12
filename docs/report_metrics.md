# Report metrics and assumptions

Both reports include sales with a non-null `order_date`. Orders are counted with
`COUNT(DISTINCT order_number)` because one order can have several sales lines.
Customers/products without any dated sale are excluded from these reports.
Monetary values and segment thresholds are expressed in euros, as in the course.

| Metric | Definition |
| --- | --- |
| Total sales | Sum of sales line amounts. |
| Total quantity | Sum of units sold. |
| Lifespan | Month boundaries between the first and last dated sale. |
| Recency | Month boundaries between the last dated sale and the current server date. |
| Average order value/revenue | Total sales divided by distinct orders, rounded to two decimal places; zero orders returns 0. |
| Average monthly spend/revenue | Total sales divided by lifespan, rounded to two decimal places; for a zero-month lifespan, use total sales. |
| Product average selling price | Average of each sales line's sales divided by quantity, rounded to one decimal place; this is not weighted by quantity. Lines with zero or NULL quantity are ignored by this average. |

Customer segments: VIP requires lifespan of at least 12 months and sales above
€5,000; Regular requires at least 12 months and sales at or below €5,000; otherwise
the customer is New. These are the course thresholds.

Product segments: High-Performer means sales above €50,000; Medium-Performer means
sales from €10,000 through €50,000; Low-Performer means sales below €10,000.

Age follows the course's `DATEDIFF(YEAR, birth_date, GETDATE())` calculation. It
counts year boundaries rather than exact birthdays. Missing birth dates have an
Unknown age group. Recency and age change with the date when the report is queried.

The cumulative price analysis is a running, unweighted average of monthly average
line prices. Performance analysis compares each product with its previous
available sales year; it can skip a calendar year with no sales. A first available
year has NULL previous-year sales and difference, but its `py_change` label is
`No Change` because it falls into the course's `ELSE` branch. That label does not
mean there was a previous year with equal sales. Product performance is grouped
by product name. Ranking ties use product name or customer key so the selected
rows are consistent for the same data; the fewest-orders query includes only
customers with sales, not customers who never ordered.

## Expected course data cases

Seven current pedal products have category ID `CO_PE` without an ERP category
match. Their category and subcategory remain NULL. The warehouse preserves the
intentionally old course birth dates. These cases are not repaired here.

The warehouse has 19 sales rows with NULL order dates. Exploratory queries that
do not filter order dates include these rows; time analyses and report views
exclude them. Their totals can therefore differ. Script 09 customer segmentation
includes all sales amounts while its first/last-order dates ignore NULLs; the
customer report filters those rows out before calculating spending and segments.
The same thresholds can therefore produce different segment counts.

Distinct orders are counted separately for each customer or product. An order
containing several products appears in each relevant product's count, so summing
product order counts does not give the number of distinct orders overall.

## Documentation source

ChatGPT wrote these explanations from the project scripts as additional
documentation. They describe the current course calculations and the changes
reviewed for this project.
