# Week 5 Assignment – Task 2: Spark Fundamentals (Theory & Code Questions)

## Objective

The goal of this task was to answer theory questions and complete coding exercises to build a deeper understanding of Apache Spark internals (like in-memory computing, DAGs, wide vs. narrow transformations, and the shuffle process) and to write practical PySpark queries for data cleaning, filtering, and aggregation. 

I used the same synthetic e-commerce transactions dataset from Task 1 on Databricks Community Edition.

---

## What I Did & What I Learned

Here is a breakdown of all the questions I worked on, my solutions, and the code I ran in my Databricks notebook.

### 1. MapReduce vs. Spark (Q1 & Q2)
I compared traditional MapReduce with Apache Spark to understand why Spark is the go-to for big data processing:
* **Disk vs. Memory:** MapReduce is really slow because it writes intermediate results to disk (HDFS) after every map or reduce stage. If you are running an iterative machine learning algorithm (like Gradient Descent) with 100 iterations, MapReduce has to do 100 disk read/write cycles. 
* **In-Memory Caching:** Spark speeds this up by loading the dataset into memory once and keeping it there using `.cache()` or `.persist()`. The intermediate iterations read directly from RAM, and only the final result is written to disk. This can make Spark up to **100x faster** for ML workloads!
* **APIs & Boilerplate:** MapReduce requires a lot of verbose Java boilerplate. PySpark lets me write concise Python code. Also, MapReduce only gives you Map and Reduce operations, whereas Spark has rich high-level transformations like `filter`, `join`, and `groupBy` out of the box.

---

### 2. Practical Coding Exercises (Q3, Q4, Q6, Q8, Q12, Q13, Q15)

I wrote and executed several PySpark queries to manipulate and clean the dataset:

* **Removing Duplicates (Q3):** I removed duplicate records based on a specific set of columns (`user_id` and `transaction_date`) using `dropDuplicates()`.
  ```python
  df_no_duplicates = df.dropDuplicates(["user_id", "transaction_date"])
  ```
  * *Result:* The row count went from **1,000** down to **970** (removed 30 duplicates). I verified this by running a group-by count and filtering for counts > 1, which returned an empty DataFrame.

* **Filtering & Aggregating (Q4):** I filtered for transactions in the `West` region and calculated the average `sale_amount` for each product category:
  ```python
  west_avg_sales = df.filter(col("region") == "West") \
      .groupBy("product_category") \
      .agg(avg("sale_amount").alias("avg_sale_amount")) \
      .orderBy(col("avg_sale_amount").desc())
  ```
  * *Result:* Electronics had the highest average sale amount in the West (₹535.63), while Toys had the lowest (₹423.16).

* **Aggregating with Thresholds (Q6):** I found the total count of records per city, keeping only those cities with more than 100 transactions:
  ```python
  city_counts = df.groupBy("city") \
      .agg(count("*").alias("total_records")) \
      .filter(col("total_records") > 100) \
      .orderBy(col("total_records").desc())
  ```
  * *Result:* Only 5 cities made the cut:
    
    | City | Total Records |
    | :--- | :--- |
    | New York | 120 |
    | Los Angeles | 113 |
    | Chicago | 111 |
    | Houston | 109 |
    | Phoenix | 108 |

* **Complex Filtering (Q8):** I filtered for users aged between 18 and 30 (inclusive) who have a `Premium` subscription using `.between()` and the logical `&` operator:
  ```python
  filtered_df = df.filter(
      (col("age").between(18, 30)) & 
      (col("subscription") == "Premium")
  )
  ```
  * *Result:* Found **67 records** matching these exact demographic criteria.

* **Cleaning Bad Rows (Q12):** I identified and removed rows where `email` is null OR `username` is an empty string `""`:
  ```python
  df_cleaned = df.filter(
      ~((col("email").isNull()) | (col("username") == ""))
  )
  ```
  * *Result:* Found **28 rows** that met this bad condition, and removing them cleaned up our dataset from 1000 to **938 rows** (some rows had multiple dirty fields).

* **Multi-Metric Aggregations (Q13):** I used `.agg()` to calculate the min, max, and mean of the `price` column simultaneously:
  ```python
  df.agg(
      min("price").alias("min_price"),
      max("price").alias("max_price"),
      avg("price").alias("mean_price")
  ).show()
  ```
  * *Result:* Min Price: ₹5.69, Max Price: ₹498.17, Mean Price: ₹250.64.

* **Final Processing Pipeline (Q15):** I combined these operations into a clean, chained pipeline that removes duplicates, fills missing prices and sale amounts with 0, groups by `store_id`, calculates total revenue and transactions, and orders the stores by revenue:
  ```python
  pipeline_result = (
      df
      .dropDuplicates()
      .fillna({"price": 0, "sale_amount": 0})
      .groupBy("store_id")
      .agg(
          F.round(F.sum("sale_amount"), 2).alias("total_revenue"),
          F.count("*").alias("total_transactions"),
          F.round(F.avg("sale_amount"), 2).alias("avg_revenue_per_txn")
      )
      .orderBy(F.col("total_revenue").desc())
  )
  ```
  * *Result:* Top performer was `STORE_013` (₹32,506.29 revenue) and the lowest was `STORE_008` (₹16,506.02 revenue).

---

### 3. Data Integrity & Nuances (Q5, Q7, Q9, Q10, Q14)

* **na.drop() vs. na.fill() (Q5):** 
  * `na.drop()` removes entire rows that have nulls. It shrinks your dataset.
  * `na.fill()` replaces nulls with a default value, keeping the row count intact.
  * *My Action:* Since `status` had 404 null values, dropping them would lose 40% of our data. I filled them with `"Unknown"` instead to preserve the rows for other analyses.

* **DataFrame Immutability (Q7):**
  * Spark DataFrames are immutable. Calling `df.drop("raw_timestamp")` does not change `df` at all; it just returns a new DataFrame.
  * To actually save the change, I had to assign it to a new variable (or overwrite the old one): `df_dropped = df.drop("raw_timestamp")`.
  * *Benefit:* This makes debugging easy. If a cleaning step goes wrong, my original data is still safe in memory. It also makes Spark fault-tolerant because it can always recompute lost partitions using the lineage graph.

* **Nulls & Math Aggregations (Q9):**
  * Spark ignores nulls during aggregations. 
  * I ran an experiment comparing:
    1. Averaging `sale_amount` with nulls ignored (average sale = ₹500.41, based on 949 rows).
    2. Averaging `sale_amount` after filling nulls with 0 (average sale = ₹474.90, based on 1000 rows).
  * *Takeaway:* Leaving nulls as-is ignores them, which artificially inflates your averages. You have to clean them first depending on the business logic!

* **Type Casting & Renaming (Q10):**
  * I cast `raw_timestamp` to a `TimestampType` and renamed it to `event_time`:
  ```python
  df_with_event_time = df \
      .withColumn("raw_timestamp", col("raw_timestamp").cast(TimestampType())) \
      .withColumnRenamed("raw_timestamp", "event_time")
  ```

* **The Danger of `inferSchema = True` with Dirty Dates (Q14):**
  * When loading data, `inferSchema=True` tells Spark to guess column types. But if dates are written in mixed formats (like some `yyyy-MM-dd` and some `dd/MM/yyyy`), Spark gets confused and reads the column as a `string`.
  * If you try to force cast it to timestamp (`cast(TimestampType())` or `try_cast`), Spark silently turns the mismatched formats into `null`!
  * *Proof:* I tried casting `raw_timestamp` and **lost 102 rows** of date information because they were in `dd/MM/yyyy` format.
  * *Solution:* I wrote a `to_timestamp()` parsing function with the correct date format pattern to process the column safely without losing data.

---

### 4. Wide vs. Narrow Transformations & Shuffling (Q11)

* **Narrow Transformations:** Operations like `filter()` or `withColumn()` are narrow because each input partition contributes to only one output partition. Data stays on the same node—no network traffic.
* **Wide Transformations & Shuffle:** Operations like `groupBy()` or `join()` require data with the same key to be grouped together. Since the data is randomly scattered across different partitions on different nodes, Spark has to shuffle (redistribute) the data across the network.
* **Why Shuffling is Expensive:** Shuffling requires writing data to disk, sending it over the network, and reading it back (deserialization). It is the biggest bottleneck in Spark jobs.
* **Execution Plan Analysis:** I ran `.explain()` on my grouped DataFrame. In the physical plan, I identified `PhotonShuffleExchangeSink` and `PhotonShuffleExchangeSource` stages, which visually confirmed that a Shuffle Exchange was taking place.

---

## How to Run the Notebook

1. Open **Databricks Community Edition**.
2. Upload the notebook `week5_assignment2.ipynb` to your workspace.
3. Make sure the dataset `asigment5.csv` is uploaded to the Unity Catalog Volume / DBFS path (`/Volumes/workspace/default/assigment5/asigment5.csv`).
4. Attach an active Spark cluster.
5. Run all cells from top to bottom.

---

## Author

**CEI Intern**  
Week 5, Task 2 Assignment  
June 2026
