# SQL Data Analytics Project

Welcome to my **SQL Data Analytics Project** repository! 🚀

This is my SQL analytics portfolio project, completed while following [Data With Baraa's SQL course](https://github.com/DataWithBaraa/sql-data-analytics-project). It builds on my [SQL Data Warehouse Project](https://github.com/BartBoi/sql-data-warehouse-project) to explore customer behaviour, product performance, and sales trends.

---

## 📖 Project Overview

This project involves:

1. **Exploration** of database structure, dimensions, dates, and business measures.
2. **Magnitude and ranking analysis.**
3. **Changes over time, cumulative sales, and product performance comparisons.**
4. **Customer segmentation and category contributions to total sales.**
5. **Reusable customer and product report views.**

---

## ▶️ How to Run

### Prerequisites

- Use **SQL Server 2022 or later**. The time analyses use `DATETRUNC`, which was introduced in SQL Server 2022.
- Build and load the [warehouse project](https://github.com/BartBoi/sql-data-warehouse-project) using the instructions in its respective README. This analytics repository uses that existing database; it does not create or reload the warehouse.
- Connect with a SQL client such as **VS Code** with the **Microsoft SQL Server extension**, and select the **DataWarehouse** database.

### Run the Analysis Scripts

1. Run each script as a separate query, in filename order. Start with [database exploration](scripts/00_database_exploration.sql).
2. Run the two report scripts in full to create/update `gold.report_customers` and `gold.report_products`. `CREATE OR ALTER VIEW` makes these scripts rerunnable.
3. Run [report checks](tests/quality_checks_reports.sql). They require both report views. A successful run prints `All report checks passed.`

Run scripts separately rather than pasting them all into one batch: view definitions must start their own batch. The report scripts need permission to create/alter views in `gold`; exploratory scripts only read data.

### Report Quality Checks

The report checks were created by **ChatGPT** to help confirm the functionality of scripts 11 and 12, which create the customer and product reports. These checks were not covered in Data With Baraa's course and were added as an extra validation step.

### Query the Result

Example report queries:

```sql
SELECT TOP (10) *
FROM gold.report_customers
ORDER BY total_sales DESC, customer_key;

SELECT TOP (10) *
FROM gold.report_products
ORDER BY total_sales DESC, product_key;
```

### Expected Warehouse Inputs

These are warehouse input counts and totals, not the counts or totals of the filtered report views.

| Dataset or measure | Expected value |
| --- | ---: |
| Customers | 18,484 |
| Current products | 295 |
| Sales lines | 60,398 |
| Total sales | €29,356,250 |
| Total quantity | 60,423 units |

---

## 🏗️ Data Model

The inputs are the warehouse's Gold views: `gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`.

![Gold star schema](docs/Sales%20Data%20Mart%20%28Star%20Schema%29%20Gold.drawio.png)

This is the same diagram used in my warehouse project. The [editable Draw.io file](docs/Sales%20Data%20Mart%20%28Star%20Schema%29%20Gold.drawio) is included in `docs`. The key labels show logical relationships between the views; these are not physical primary-key or foreign-key constraints.

See the [data dictionary](docs/data_catalog.md) and [report metrics and assumptions](docs/report_metrics.md).

### Data and Calculation Notes

Seven current pedal products have unmatched category details in the course data. Old birth dates are retained as course examples. Report views exclude sales with missing order dates. Age uses the course's approximate year-boundary calculation, and current age/recency depend on when you query the reports. See [metric definitions](docs/report_metrics.md) for the remaining calculation details.

---

## 📂 Repository Structure

```text
Exploratory Data Analysis Project/
│
├── datasets/       # Data-source instructions linking to the warehouse
│
├── docs/           # Data model diagram, dictionary, metric definitions, and validation record
│
├── scripts/        # 00–12: exploration, analysis, and report views
│
├── tests/          # Report reconciliation checks
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## 🙏 Attribution

The project follows **Data With Baraa's course** and uses its warehouse datasets and analysis exercises. I adapted the scripts to my warehouse column names and added rerunnable views, decimal calculations, and stable ranking ties.

**ChatGPT** helped prepare the structure of this repository and create supporting files that were not included in the course material, such as the tests and additional Markdown (`.md`) documentation. It also tested the scripts to check their functionality. You can see the [validation record here](docs/validation.md).

---

## 🛡️ License

My contributions are provided under the [MIT License](LICENSE). Original course materials remain subject to their original license and attribution requirements.
