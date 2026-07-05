# Week 6 Assignment - PySpark on Databricks

This is my week 6 assignment for the CEI internship where I worked with PySpark on Databricks. The whole assignment is based on an e-commerce orders dataset that has 1000 records with details like order info, customer details, product categories, pricing, discounts, payment methods, and customer ratings. The assignment is split into two tasks - task 1 is hands-on practice with PySpark DataFrame operations and task 2 is answering theory + code based questions on Spark concepts.

## Folder Structure

### raw_dataset/

This folder has the original dataset files that I used as input for both tasks.

- ecommerce.csv - the raw e-commerce dataset in CSV format (around 148KB). This has all 1000 orders with 15 columns like order_id, customer_name, email, product_category, product_name, quantity, unit_price, discount_percent, total_amount, order_date, city, country, payment_method, order_status, and rating. This file has null values in several columns and the data is not cleaned.

- ecommerce.parquet - same dataset but in Parquet format (around 51KB). This is the file I loaded in Databricks for most of my work. You can clearly see the size difference - parquet is much smaller than CSV because of columnar storage and compression.

### task-1/

This folder has everything related to the hands-on PySpark practice.

- task1-week6.ipynb - this is the main Databricks notebook where I did all the DataFrame operations. I started with reading and exploring the data, then moved to filtering and selecting columns, handling null values column by column, modifying the dataframe (renaming columns, casting datatypes, adding new columns), understanding transformations vs actions, checking predicate pushdown through explain plans, comparing CSV vs Parquet performance (read times and file sizes), and finally building a complete data pipeline (read → transform → filter → write). All the code and outputs are in this notebook.

- README.md - detailed explanation of everything I did in task 1 and the insights I gained from it.

### task-2/

This folder has the assignment questions notebook and its output.

- task2-week6.ipynb - this notebook has 15 questions (mix of theory and code). The theory questions cover Spark architecture (Driver, Cluster Manager, Executor), lazy evaluation, CSV vs Parquet differences, lineage graph and fault tolerance, predicate pushdown, transformations vs actions, client mode vs cluster mode, and why show() is safer than collect() on large data. The code questions are about reading CSV files, filtering with conditions (AND/OR), selecting specific columns, renaming columns and casting datatypes, adding new calculated columns, and writing a read-filter-write pipeline. For every code question I demonstrated the answer using the actual e-commerce dataset and also wrote the generic syntax.

- res_dataset/ - this subfolder has the output file from the Q12 pipeline question where I read the parquet file, filtered out null values, and wrote the cleaned result as a CSV.
  - cleaned_dataset.csv - the output CSV file from that pipeline (around 139KB, 1001 rows including header). This is the e-commerce data after filtering out rows with null email values.

### cleaned_dataset/

This folder has the cleaned dataset files that I generated as output from task 1 after handling all the null values.

- cleaned_dataset.parquet - the final cleaned parquet file from task 1. After handling nulls in email (filled with "Not Provided"), quantity (dropped rows where null), discount_percent (calculated from other columns), payment_method (filled with "Unknown"), and rating (filled with average rating), I saved the result here. All columns have zero null values in this file.

- cleaned_ecommerce.parquet - another copy of the cleaned dataset in parquet format. Same data as cleaned_dataset.parquet.

## What Each Task Is About

### Task 1 - Hands-On PySpark DataFrame Operations

This was the main practice task where I worked through various PySpark operations step by step on the e-commerce dataset. It covers reading data from parquet files, exploring the schema and records, selecting and filtering data with single and multiple conditions, finding and handling null values across all columns, modifying dataframes (renaming, casting, adding columns), understanding lazy evaluation through transformations and actions, checking query execution plans for predicate pushdown, comparing CSV vs Parquet read performance, and building a complete data pipeline from raw data to cleaned output. The cleaned output is saved in the cleaned_dataset folder.

### Task 2 - PySpark Theory and Code Questions

This was a set of 15 questions testing both theoretical understanding and practical coding skills. The theory questions go into Spark internals like how the driver-executor architecture works, why lazy evaluation improves performance, how the lineage graph provides fault tolerance, what predicate pushdown does, and the difference between client and cluster mode. The code questions asked me to write PySpark queries for common operations like reading files, filtering, selecting, renaming, casting, adding columns, and building mini pipelines. The output from the pipeline question is saved in the res_dataset folder inside task-2.
