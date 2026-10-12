# Final validation — 9 October 2026

**Result: Passed.** All 13 analytics scripts (00–12) executed successfully against the local `DataWarehouse` database. Both report definitions were run a second time to confirm that they can be rerun, and all report quality checks passed.

## Checks performed

- Executed the exploration, analysis, and report scripts in filename order.
- Created or updated `gold.report_customers` and `gold.report_products`, then repeated both definitions.
- Checked for duplicate customer and product report keys.
- Compared each report's sales and quantity totals with source sales that have a valid order date.
- Compared distinct order counts for each customer and product with the source sales.
- Checked missing-age labels and the €5,000 Regular customer boundary where applicable in the existing data.
- Confirmed the warehouse input counts and totals shown in the README.
- Checked local Markdown links, including the diagram and documentation links.

## Results

| Warehouse input | Verified value |
| --- | ---: |
| Customers | 18,484 |
| Current products | 295 |
| Sales lines | 60,398 |
| Total sales | €29,356,250 |
| Total quantity | 60,423 units |

Both reports exclude sales with NULL order dates. Their totals matched the remaining 60,379 sales lines:

| Report | Rows | Total sales | Total quantity |
| --- | ---: | ---: | ---: |
| Customer report | 18,482 | €29,351,258 | 60,404 units |
| Product report | 130 | €29,351,258 | 60,404 units |

Report row counts include only customers and products with a dated sale, so they differ from the full warehouse input counts.

The successful run finished with `All report checks passed.` and `FINAL VALIDATION PASSED`. SQL Server produced expected warnings about NULL values being ignored by aggregates; there were no SQL errors in this run.

## Test environment and method

The scripts were executed through the saved local VS Code SQL connection on SQL Server 2022, version `16.0.4295.3`. The successful SQL run took approximately 66 seconds.

The test used one transaction and rolled it back after the checks. The original report view definitions were verified as restored. No source data was reloaded, and no permanent database changes were made. The project SQL files were unchanged during validation. Run scripts 11 and 12 to install the report definitions permanently.

## Scope and attribution

ChatGPT created and ran the extra report checks to help confirm the functionality of the scripts. These checks were not included in Data With Baraa's course.

This validates the current scripts against the existing local warehouse and checks the listed conditions in its data. It does not test every possible future dataset or a fresh SQL Server installation. Source data and warehouse setup are provided by the [SQL Data Warehouse Project](https://github.com/BartBoi/sql-data-warehouse-project).
