# Week 6 - Task 2: PySpark Assignment Questions

This task was a set of 15 theory and code-based questions on PySpark concepts. I answered all of them in the notebook, and for the code questions I demonstrated the answers using the same e-commerce dataset from task 1 along with providing the generic syntax that the question was asking for.

## What I Covered

### Q1 - Spark Architecture (Driver, Cluster Manager, Executor)

I explained the three main components. The Driver is basically the brain - its the main process that runs our code, builds the execution plan (DAG), and coordinates everything. The Cluster Manager (like YARN, Kubernetes, or Spark standalone) handles resource allocation across the cluster, so when the driver needs executors it talks to the cluster manager. The Executors are the actual worker processes that run on cluster nodes and do the heavy lifting - they execute the tasks and store data in memory or disk.

### Q2 - Lazy Evaluation

I explained how Spark doesnt run transformations immediately. It just records them and builds a plan. Only when we call an action like show() or count() does it actually execute. This is smart because Spark gets to see the whole chain of operations before running anything, so it can optimize through the Catalyst optimizer - like pushing filters before selects to reduce data early, or combining operations to avoid multiple disk reads. Without lazy evaluation, Spark would have to materialize intermediate results at every step which would be really slow.

### Q3 - Reading CSV with Header and InferSchema

I wrote the command to read a CSV file with header=True (so the first row is treated as column names) and inferSchema=True (so Spark figures out the datatypes automatically instead of treating everything as strings). Demonstrated it with the actual dataset and also provided the generic syntax.

### Q4 - CSV vs Parquet

I explained the core difference - CSV is row-based (stores data row by row) while Parquet is columnar (stores all values of one column together). This matters because if you only need 2 columns out of 15, Parquet can skip the other 13 entirely (column pruning) while CSV has to read through everything. Parquet also compresses better since similar values in a column compress more efficiently, and it stores min/max metadata per column chunk enabling predicate pushdown. CSV cant do any of this.

### Q5 - Select with Filter

I wrote a query to select specific columns (order_id, unit_price) where the product_category is Electronics. Used both .select() and .filter() chained together. Also showed the generic syntax as the question asked for product_id and price where category is Electronics.

### Q6 - Rename Column and Cast Datatype

I demonstrated renaming customer_name to buyer_name using withColumnRenamed() and casting unit_price to DoubleType using withColumn() and cast(). Verified by printing the schema to confirm the changes. Also provided the generic syntax for renaming old_name to new_name and casting price from String to Double.

### Q7 - Lineage Graph and Fault Tolerance

I explained how Spark records a "recipe" (lineage) of how each RDD/DataFrame was created through transformations. This forms a DAG. So if a worker node crashes and data is lost, Spark can look at the lineage and replay just the transformations needed to recreate the lost partitions. It doesnt recompute everything - just the specific partitions that were lost. This is why Spark doesnt need data replication like Hadoop. I also mentioned persist() and checkpoint() for long chains where recomputation would be expensive.

### Q8 - Filtering with AND Condition

I wrote a query filtering orders where order_status is "Delivered" AND total_amount is greater than 1000 using the & operator. The key thing here is wrapping each condition in parentheses because of Python operator precedence. Showed the output with selected columns to verify it worked.

### Q9 - Predicate Pushdown

I explained this concept in detail - its about pushing filter conditions down to the storage layer instead of loading all data first. Parquet stores min/max metadata per row group, so Spark can check if a chunk could possibly have matching rows before reading it. If a row groups max value is 500 and the filter asks for > 1000, that entire chunk is skipped. This massively reduces disk I/O and memory usage. CSV cant do this at all since it has no metadata.

### Q10 - Adding a New Column with Tax Calculation

I used withColumn() to add a final_price column calculated as unit_price * 1.18 (18% tax). Showed the output with order_id, product_name, unit_price, and the new final_price to verify the calculation was right.

### Q11 - Transformations vs Actions

I explained the difference clearly. Transformations (like filter, select) are lazy - they just build the execution plan and return a new DataFrame. Actions (like show, count) are eager - they actually trigger the computation. I gave two examples of each and also wrote a code demo where I applied filter and select (transformations) and nothing happened until I called show() and count() (actions).

### Q12 - Read Parquet, Filter Nulls, Write CSV

I wrote the full pipeline - read a parquet file using spark.read.parquet(), filter out null rows using isNotNull(), and write the result as CSV with header=True and mode="overwrite". Demonstrated with our dataset (filtering null emails - went from 1000 to 953 rows) and also provided the generic syntax with user_id as the question asked.

### Q13 - Client Mode vs Cluster Mode

I explained the key difference - its about where the driver runs. In Client Mode, the driver stays on the machine that submitted the job (good for interactive work like notebooks and debugging, but if the client disconnects the job dies). In Cluster Mode, the driver runs inside the cluster on a worker node (better for production jobs since the client can disconnect and the job keeps running, but harder to debug). I also noted that Databricks uses cluster mode by default.

### Q14 - Filtering with OR Condition

I wrote a query using the | (OR) operator to filter rows matching either condition. Used our dataset columns (country == "Japan" OR product_category == "Electronics") and also provided the generic syntax for region == "North" OR priority == "High".

### Q15 - show(5) vs collect() on Large Data

I explained why collect() is dangerous on big datasets - it pulls the ENTIRE dataset to the driver machine as a Python list, which can crash it with OutOfMemoryError if the data is multi-terabyte. show(5) only fetches 5 rows to the driver and Spark is smart enough to only read enough partitions to fill those 5 rows. My rule of thumb is to use show() or take() for exploration and only use collect() when the data is guaranteed to be small.

## Insights I Gained

Going through these questions really helped me connect the theory with what I was doing in task 1. Like when I was doing the predicate pushdown explain() in task 1, I understood what was happening but answering Q9 here made me articulate it properly - understanding why Parquet metadata matters and how Spark skips row groups.

The fault tolerance question (Q7) was interesting because I hadnt really thought about why Spark doesnt replicate data like HDFS does. The lineage approach is elegant - instead of keeping copies of data, just keep the recipe to recreate it. Though the trade-off is that recomputation can be expensive for long chains, which is where caching and checkpointing come in.

The Client Mode vs Cluster Mode distinction (Q13) was new for me. Since I was using Databricks, I never had to think about this, but its important to know for when you deploy Spark jobs in production. Client mode is what we use in notebooks for interactive development, but real batch jobs should run in cluster mode so they dont depend on the client staying alive.

The show() vs collect() thing (Q15) seems obvious but its actually a common mistake. Ive seen people use collect() on large dataframes without thinking and it just kills the driver. Now I always check the expected size before using collect().

Overall this task was good for solidifying my understanding of Spark internals - not just the syntax but the "why" behind how things work.
