# Week 7 Assignment - Delta Lake SCD (Type 1 and Type 2) Implementation

## Objective

Perform incremental data processing using Delta Lake. This assignment implements Slowly Changing Dimensions (SCD) Type 1 (overwrite) and SCD Type 2 (history tracking) in PySpark on Databricks.

## Dataset

- `Sample - Superstore.csv`: Original transaction dataset containing 9,994 records.
- `customer_master.csv`: Cleaned, unique customer master records (793 records) extracted from the Superstore dataset.
- `customer_incremental.csv`: Incremental dataset containing 5 records (3 updates to existing customers, 2 new customer records).

## Project Structure

```
week-7-Assignment/
├── data/
│   ├── Sample - Superstore.csv
│   ├── customer_master.csv
│   └── customer_incremental.csv
├── notebooks/
│   └── delta_scd_assignment.ipynb
├── screenshots/
│   ├── data_loading/
│   ├── data_cleaning/
│   ├── scd1/
│   ├── scd2/
│   ├── validation/
│   └── final_output/
├── report/
│   └── .gitkeep
└── README.md
```

## What I Did

1. **Data Extraction**: Extracted unique customers from `Sample - Superstore.csv` based on `Customer ID` to build the customer master data, and simulated an incremental updates dataset.
2. **Data Cleaning**: Loaded the master CSV, performed null check validation, dropped duplicate customer keys, and loaded it into a managed Delta table `customer_master_delta`.
3. **SCD Type 1 (Upsert)**:
   - Merged `customer_incremental.csv` into `customer_master_delta` using `Customer_ID` as the merge key.
   - Updated existing customer details (overwrite) and inserted new customers.
   - Validated row counts: 793 original + 2 new inserts = 795 rows. Verified updates for the 3 modified customers.
4. **SCD Type 2 (History Tracking)**:
   - Created a separate Delta table `customer_scd2_delta` with tracking columns: `is_current` (boolean), `start_date` (date), and `end_date` (date).
   - Executed SCD Type 2 merge logic:
     - Step 1: Expired old matching active records by setting `is_current = false` and `end_date = current_date()`.
     - Step 2: Inserted new active records (both brand new customers and new versions of updated customers) with `is_current = true`, `start_date = current_date()`, and `end_date = null`.
   - Validated results: 793 original + 2 new inserts + 3 history rows = 798 rows. Verified updated customers now have two historical records (one active, one inactive).
5. **Delta Table History**: Inspected the version history of the Delta tables using `.history()`.
6. **Summary & Aggregations**: Analyzed customer distribution across business segments and regions.

## How to Run

1. Upload `customer_master.csv` and `customer_incremental.csv` from the `data/` folder to Databricks DBFS (`/FileStore/tables/`).
2. Import the notebook `notebooks/delta_scd_assignment.ipynb` into your Databricks workspace.
3. Attach a Spark cluster and run all cells.
4. Capture screenshots and place them in the corresponding folders under `screenshots/`.

## Technologies

- PySpark
- Delta Lake
- Databricks

