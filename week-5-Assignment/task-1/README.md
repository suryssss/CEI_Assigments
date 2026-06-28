# Week 5 Assignment – Spark Fundamentals: Data Cleaning, Transformation & Aggregation

## Objective

The goal of this assignment was to understand Apache Spark fundamentals and perform data cleaning, transformation, and aggregation using PySpark DataFrames on Databricks.

---

## Dataset

The dataset used for this assignment is a synthetic e-commerce transactions dataset (`spark_assignment_dataset.csv`) containing **1,000 records** with the following columns:

| Column | Type | Description |
|---|---|---|
| user_id | int | Unique user identifier |
| transaction_date | date | Date of the transaction |
| city | string | City where the transaction occurred |
| region | string | Geographic region (West, South, East, Midwest, Central) |
| product_category | string | Category of the product purchased |
| sale_amount | double | Total sale value |
| price | double | Price of the item |
| subscription | string | User's subscription tier (Free, Basic, Premium, Enterprise) |
| age | int | Age of the user |
| store_id | string | Identifier for the store |
| status | string | Transaction status (Active, Inactive, Pending, NULL) |
| email | string | User's email |
| username | string | User's username |
| raw_timestamp | string | Raw timestamp string |

---

## Tools & Environment

- **Platform**: Databricks (Community Edition)
- **Language**: PySpark (Python)
- **Spark**: Pre-configured on Databricks, no manual SparkSession setup needed

---

## What I Did

### 1. Loaded the Dataset & Explored It

I started by loading the CSV file into a Spark DataFrame using `spark.read.csv()` with `header=True` and `inferSchema=True`. Then I explored the data using `.show()`, `.printSchema()`, `.describe()`, `.count()`, `.columns`, and `.dtypes` to understand the shape, schema, and basic statistics of the dataset.

**Key observations from exploration:**
- Dataset had 1,000 rows and 14 columns
- `sale_amount` and `price` had only 949 non-null values out of 1,000
- `status` column had many NULL entries
- `raw_timestamp` had inconsistent date formats (some in `yyyy-MM-dd`, others in `dd/MM/yyyy`, and some with ISO format `T00:00:00Z`)

### 2. Understood DataFrame Immutability

I tested Spark's immutability concept by creating a new DataFrame with `withColumn("add_age", col("age") + 10)` and then checked the original DataFrame — it remained unchanged. This confirmed that every transformation in Spark creates a new DataFrame and the original data stays untouched. This is a core design principle of Spark that helps with fault tolerance and parallel processing.

### 3. Chained Transformations

I practiced chaining multiple transformations together in a single pipeline expression:
```python
df_pipeline = df \
    .filter(col("age") > 18) \
    .withColumn("age_double", col("age") * 2) \
    .select("user_id", "age", "age_double", "region")
```
This helped me understand how Spark uses lazy evaluation — none of these transformations actually execute until an action (like `.show()`) is called.

### 4. Data Cleaning

#### Removing Duplicates
- Used `.groupBy(df.columns).count().filter(col("count") > 1)` to identify exact duplicate rows
- Also checked for duplicates on key columns (`user_id`, `transaction_date`, `store_id`) to find duplicate transactions
- Found **30 duplicate rows** and removed them using `.dropDuplicates()`, bringing the count from 1,000 to **970**

#### Handling Null Values
- Used a null count check across all columns and found:
  - `sale_amount`: 49 nulls
  - `price`: 49 nulls (same rows as sale_amount — both were missing together)
  - `status`: 394 nulls
  - `email`: 27 nulls
  - `username`: 33 nulls
- **sale_amount & price**: Dropped these 49 rows using `.dropna(subset=["sale_amount", "price"])` since there was no sales data to work with
- **status**: Filled 374 null values with `"Unknown"` using `.fillna()` — couldn't drop these since it would lose too much data
- **email & username**: Filled nulls with `"Not Available"` and `"Unknown"` respectively

After cleaning, the dataset had **921 clean records** with **zero null values** in any column.

### 5. Filtering

I applied various filtering conditions to the cleaned dataset:

- **Age range filter**: Filtered users aged 18–40 → returned **405 records**
- **Category filter**: Filtered for `Electronics` → **111 records**
- **Multi-category filter**: Filtered for `Electronics` and `Clothing` using `.isin()` → **226 records**
- **Region filter**: Filtered for `West` region → **348 records**
- **Combined filter**: Age 20–40 AND West region AND Electronics category → returned a targeted subset for analysis

### 6. Aggregation Functions

I used Spark's built-in aggregation functions on the cleaned dataset:

| Metric | Value |
|---|---|
| Total Transactions | 921 |
| Total Sales | ₹4,61,800.21 |
| Average Sale Amount | ₹501.41 |
| Average Age | 41.53 years |
| Minimum Sale | ₹11.56 |
| Maximum Sale | ₹994.00 |
| Youngest Customer | 16 years |
| Oldest Customer | 65 years |

### 7. GroupBy & Aggregated Conditions

#### Sales by Region
| Region | Total Sales | Avg Sales | Transactions |
|---|---|---|---|
| West | 1,76,189.63 | 506.29 | 348 |
| South | 1,30,452.32 | 507.60 | 257 |
| East | 99,340.71 | 509.44 | 195 |
| Midwest | 49,757.16 | 469.41 | 106 |
| Central | 6,060.39 | 404.03 | 15 |

**Insight**: West region dominates with the highest total sales and most transactions. Central region has significantly fewer transactions (only 15), which makes sense since it only includes cities like Las Vegas.

#### Sales by Product Category
| Category | Total Sales | Avg Sales | Transactions |
|---|---|---|---|
| Books | 61,238.07 | 489.90 | 125 |
| Food | 61,170.38 | 514.04 | 119 |
| Beauty | 59,157.07 | 518.92 | 114 |
| Clothing | 58,875.54 | 511.96 | 115 |
| Electronics | 56,169.94 | 506.04 | 111 |
| Home | 56,229.59 | 493.24 | 114 |
| Toys | 54,625.64 | 470.91 | 116 |
| Sports | 54,333.98 | 507.79 | 107 |

**Insight**: All categories are fairly evenly distributed in terms of transactions (107–125 range). Beauty has the highest average sale (₹518.92) while Toys has the lowest (₹470.91). Books lead in total volume with 125 transactions.

#### Low-Performing Segments
Filtered for segments with total sales < 1,000 and transactions < 50 — all low performers were from the **Central** region (Clothing, Home, Books, Electronics, Sports), confirming Central is an underperforming market.

### 8. Wide Transformations & Shuffle Operations

- Performed **store-wise revenue aggregation** using `groupBy("store_id")` which is a **wide transformation** — it requires shuffling data across partitions
- Used `.explain(True)` to inspect the physical execution plan and observed:
  - `PhotonShuffleExchangeSink` and `PhotonShuffleExchangeSource` stages confirming data shuffle
  - Hash partitioning on the group key (`store_id`)
  - The query was fully supported by **Photon** (Databricks' native vectorized engine)
- Also demonstrated a **narrow transformation** (`.filter(col("region") == "East")`) which doesn't require shuffle — data stays within the same partition

### 9. Schema Modification

- **Casting**: Explicitly cast `age` to `int`, `sale_amount` to `double`, and `price` to `double` using `.cast()`
- **Renaming**: Renamed columns for readability:
  - `transaction_date` → `txn_date`
  - `product_category` → `category`
  - `store_id` → `store`
  - `sale_amount` → `sales`

### 10. Handling Inconsistent Data

After all the cleaning steps, I ran a final null check across all columns and confirmed **zero nulls** in the entire dataset. The `raw_timestamp` column still had inconsistent date formats (e.g., `2024-03-15 00:00:00`, `19/05/2023 00:00`, `2023-06-22T00:00:00Z`) but was kept as-is since it wasn't used in any analysis.

### 11. Complete Data Processing Pipeline

As the final step, I built a complete end-to-end pipeline that combines all cleaning and aggregation steps into a single chained expression:

```python
pipeline_df = (
    df.dropDuplicates(["user_id", "txn_date"])
    .withColumn("username", F.trim(F.col("username")))
    .withColumn("email", F.trim(F.col("email")))
    .withColumn("city", F.trim(F.col("city")))
    .withColumn("region", F.trim(F.col("region")))
    .withColumn("status", F.trim(F.col("status")))
    # Handle empty strings as nulls
    .withColumn("username", F.when(F.col("username") == "", None).otherwise(F.col("username")))
    .withColumn("email", F.when(F.col("email") == "", None).otherwise(F.col("email")))
    .withColumn("status", F.when((F.col("status").isNull()) | (F.col("status") == ""), "Unknown").otherwise(F.col("status")))
    # Cast types
    .withColumn("price", F.col("price").cast("double"))
    .withColumn("sales", F.col("sales").cast("double"))
    .withColumn("age", F.col("age").cast("int"))
    # Fill nulls for numeric columns
    .withColumn("price", F.when(F.col("price").isNull(), 0).otherwise(F.col("price")))
    .withColumn("sales", F.when(F.col("sales").isNull(), 0).otherwise(F.col("sales")))
    # Filter valid records
    .filter(F.col("email").isNotNull())
    .filter(F.col("username").isNotNull())
    .filter(F.col("age").between(16, 65))
    # Add derived columns
    .withColumn("event_year", F.year(F.col("txn_date")))
    .withColumn("event_month", F.month(F.col("txn_date")))
    # Aggregate by store
    .groupBy("store")
    .agg(
        F.count("*").alias("total_transactions"),
        F.round(F.sum("sales"), 2).alias("total_sales"),
        F.round(F.avg("sales"), 2).alias("avg_sales"),
        F.round(F.sum("price"), 2).alias("total_price"),
        F.countDistinct("user_id").alias("unique_users")
    )
    .orderBy(F.col("total_sales").desc())
)
```

#### Pipeline Results (Top 5 Stores by Sales)

| Store | Transactions | Total Sales | Avg Sales | Total Price | Unique Users |
|---|---|---|---|---|---|
| STORE_013 | 60 | 32,506.29 | 541.77 | 15,451.96 | 60 |
| STORE_011 | 48 | 28,441.53 | 592.53 | 12,884.60 | 48 |
| STORE_014 | 48 | 26,997.01 | 562.44 | 12,532.60 | 48 |
| STORE_009 | 57 | 26,906.69 | 472.05 | 14,621.28 | 57 |
| STORE_003 | 55 | 26,625.14 | 484.09 | 14,400.63 | 55 |

**Insight**: STORE_013 leads in total sales while STORE_011 has the highest average sale per transaction (₹592.53). STORE_008 has the lowest performance with ₹16,506.02 in total sales and the lowest average (₹383.86).

---

## Key Learnings

1. **MapReduce vs Spark**: MapReduce writes intermediate results to disk after every step which makes it slow. Spark keeps data in memory (RDDs/DataFrames) which makes it much faster — especially for iterative operations like machine learning pipelines.

2. **DataFrame Immutability**: Every transformation creates a new DataFrame. The original never changes. This is what makes Spark fault-tolerant — if a partition fails, Spark can recompute it from the lineage.

3. **Lazy Evaluation**: Transformations like `.filter()`, `.withColumn()`, `.select()` are not executed immediately. Spark builds a DAG (Directed Acyclic Graph) of transformations and only executes when an action like `.show()`, `.count()`, or `.collect()` is called. This allows Spark to optimize the execution plan.

4. **Narrow vs Wide Transformations**: 
   - **Narrow** (filter, map, withColumn) → each input partition contributes to only one output partition, no data movement needed
   - **Wide** (groupBy, join, distinct) → data needs to be shuffled across partitions, which is expensive

5. **Data Quality Matters**: The raw data had duplicates, nulls, and inconsistent formats. Cleaning had to be done carefully — dropping rows where critical data was missing (sale_amount) but filling with defaults where dropping would lose too much data (status).

---
