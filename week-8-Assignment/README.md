# Week 8 Assignment: E-Commerce Order Analytics System

Final intern mini project covering Python data generation, cleaning, SQL analysis, CLI reporting, and edge-case testing.

## Project Structure

```
week-8-Assignment/
├── data/
│   ├── raw/                 # Generated CSV files with intentional data issues
│   └── cleaned/             # Cleaned CSV files after Python processing
├── db/
│   └── ecommerce.db         # SQLite database (created by load_database.py)
├── python/
│   ├── generate_data.py     # Part 1: Generate sample CSV data
│   ├── clean_data.py        # Part 2: Clean data and write issues report
│   ├── load_database.py     # Load cleaned CSVs into SQLite
│   ├── report_cli.py        # Part 4: Command-line summary reports
│   └── test_edge_cases.py   # Part 5: Edge case test functions
├── reports/
│   └── issues_report.txt    # Data quality report from cleaning step
├── sql/
│   ├── create_tables.sql    # SQLite schema
│   ├── README.md            # Query index by difficulty
│   ├── basic/               # Queries 1-3 (simple)
│   ├── intermediate/        # Queries 4-6
│   └── advanced/            # Queries 7-16 (window functions & CTEs)
└── requirements.txt
```

## Setup

```bash
cd week-8-Assignment
pip install -r requirements.txt
```

## How To Run

Run the scripts in order:

```bash
# Part 1: Generate raw data
python python/generate_data.py

# Part 2: Clean data and create issues report
python python/clean_data.py

# Load cleaned data into SQLite
python python/load_database.py

# Part 4: Interactive CLI report
python python/report_cli.py

# Part 5: Run edge case tests
python python/test_edge_cases.py
```

## Part 1: Data Generation

`generate_data.py` creates 4 CSV files with at least 500 rows each:

- `orders.csv`
- `order_items.csv`
- `products.csv`
- `customers.csv`

Intentional issues included:

- 5% of orders with missing `customer_id`
- 3% of order items with negative quantity (returns)
- Some orders with `DD-MM-YYYY` date format
- Product names with extra spaces or mixed case
- 2% invalid customer emails
- A small number of orphan `order_items` for referential integrity testing

## Part 2: Data Cleaning

`clean_data.py` provides:

- `clean_orders()` - fixes date formats and missing customer IDs
- `clean_products()` - trims and title-cases product names
- `validate_emails()` - returns customer IDs with invalid emails
- `check_referential_integrity()` - finds order items with missing orders

Outputs:

- Cleaned CSV files in `data/cleaned/`
- Issue report in `reports/issues_report.txt`

## Part 3: SQL Analysis

Open `db/ecommerce.db` and run queries from the `sql/` folder. See `sql/README.md` for the full list.

- `sql/basic/` — 3 simple queries (joins + GROUP BY)
- `sql/intermediate/` — 3 queries (subqueries + CASE)
- `sql/advanced/` — 10 queries (window functions, CTEs, self-joins)

Revenue formula used throughout:

```
revenue = quantity * unit_price * (1 - discount_percent / 100)
```

## Part 4: CLI Reporting Tool

`report_cli.py` uses only Python's built-in `sqlite3` module.

Example interaction:

```
Enter report type: weekly
Enter start date (YYYY-MM-DD): 2024-01-01
Enter end date (YYYY-MM-DD): 2024-01-07
```

The report includes:

- Total orders, revenue, unique customers
- Top 3 products
- Percentage change vs previous period

## Part 5: Edge Case Tests

`test_edge_cases.py` verifies handling for:

1. Orphan `order_id` values in `order_items`
2. `discount_percent > 100`
3. `quantity = 0`
4. Future `order_date` values

## Tools Used

- Python 3.10+
- pandas
- SQLite
