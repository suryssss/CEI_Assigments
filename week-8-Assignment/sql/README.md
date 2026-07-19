# SQL Queries

Queries are split into 3 folders by difficulty. Run `create_tables.sql` first, then load data with `python/load_database.py`.

**Revenue formula used in all queries:**

```
quantity * unit_price * (1 - discount_percent / 100)
```

## Basic (`sql/basic/`)

Simple joins and aggregations.

| File | Question |
|------|----------|
| `01_revenue_by_category.sql` | Total revenue per category |
| `02_top_10_customers.sql` | Top 10 customers by order value |
| `03_monthly_order_count.sql` | Order count by month (last 12 months) |

## Intermediate (`sql/intermediate/`)

Subqueries and conditional aggregation.

| File | Question |
|------|----------|
| `04_undelivered_customers.sql` | Customers who never got a delivery |
| `05_returns_exceed_purchases.sql` | Products with more returns than purchases |
| `06_return_rate_by_category.sql` | Return rate per category |

## Advanced (`sql/advanced/`)

Window functions, CTEs, and self-joins.

| File | Question | SQL concept |
|------|----------|-------------|
| `07_running_total_by_region.sql` | Running revenue total by region | CTE + SUM() OVER |
| `08_rank_products_by_category.sql` | Product rank within category | DENSE_RANK() |
| `09_order_gap_analysis.sql` | Days between orders, at-risk flag | LAG() |
| `10_monthly_customer_categories.sql` | High/Medium/Low customers per month | Nested CTEs |
| `11_customer_quartiles.sql` | Platinum/Gold/Silver/Bronze segments | NTILE() |
| `12_yoy_revenue.sql` | Year-over-year monthly growth | LAG() by year |
| `13_first_last_category.sql` | First vs latest category purchased | ROW_NUMBER() |
| `14_cumulative_revenue.sql` | Cumulative revenue share | Running SUM() |
| `15_cohort_retention.sql` | Retention by registration cohort | Multi-step CTE |
| `16_product_pairs.sql` | Products bought together | Self-join |

## How to run

Open `db/ecommerce.db` in DB Browser for SQLite and run one file at a time.

Example with SQLite CLI:

```bash
sqlite3 db/ecommerce.db ".read sql/basic/01_revenue_by_category.sql"
```
