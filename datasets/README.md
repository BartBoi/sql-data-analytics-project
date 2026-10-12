# Data source

These scripts use the existing `DataWarehouse` database from my
[SQL Data Warehouse Project](https://github.com/BartBoi/sql-data-warehouse-project).
Build and load that warehouse by following its README before running this project.

The inputs are `gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`.
The six source CSVs are already versioned in the warehouse repository; this
repository does not duplicate those files or include a database backup or CSV exports.

The scripts expect this project's column names: `birth_date`, `sales`, and
`ship_date`. Other copies of the course data may use different names.

See the [data dictionary](../docs/data_catalog.md) for the input columns.
