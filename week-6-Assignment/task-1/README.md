# Week 6 - Task 1: PySpark DataFrame Operations on E-Commerce Data

This is my week 6 assignment where I worked with PySpark on Databricks to perform various DataFrame operations on an e-commerce orders dataset. The dataset had 1000 records and 15 columns covering things like order details, customer info, product categories, pricing, discounts, payment methods, and ratings.

## What I Did

### Reading and Exploring the Data

First thing I did was create a Spark session and load the data from a parquet file stored in Databricks Volumes. Once I had the data loaded, I checked the basics - how many records are there (1000 rows), what columns exist, their datatypes, and the overall schema using printSchema(). The dataset had columns like order_id, customer_name, email, product_category, product_name, quantity, unit_price, discount_percent, total_amount, order_date, city, country, payment_method, order_status, and rating.

### Selecting and Filtering Data

I practiced selecting specific columns using select() - like pulling just the order_id, customer_name, and product_name. Then I stored a subset of columns into a new dataframe to work with separately.

For filtering, I used both filter() and where() to pull out records based on conditions. I filtered orders where total_amount was greater than 1000, then tried the same thing with where() and got the exact same output - so I understood that filter() and where() in PySpark are basically the same thing, just different names.

I also filtered by specific categories like Sports products, orders with ratings above 3, and orders that were still in "Processing" status.

### Multiple Conditions Filtering

Next I moved on to combining multiple conditions. I used the & (AND) operator to get orders where total_amount > 1000 AND quantity >= 5. Then I used the | (OR) operator to filter products that were either in Electronics or Appliances category. One thing I noticed is that when combining conditions in PySpark, you have to wrap each condition in parentheses otherwise it throws errors because of how Python handles operator precedence.

### Handling Null Values (First Pass)

I checked for null values across all columns and found nulls in email (47), quantity (41), discount_percent (43), total_amount (41), payment_method (125), and rating (53). This was a big chunk of the data quality work.

### Combining Select and Filter

I chained select() and filter() together to get specific columns from filtered data. For example, getting just the order_id, product_name, and total_amount for orders above 1000. Also filtered Sports category and selected only product_name and total_amount. This chaining approach made the code cleaner.

### Checking for Duplicates and Sorting

I checked if there were any duplicate order_ids by doing a groupBy on order_id and filtering for counts greater than 1. The result came back empty which means all order_ids were unique, no duplicates.

For sorting, I used orderBy() to sort data by total_amount in ascending order after filtering out nulls. This showed me the cheapest orders first.

### Modifying the DataFrame

I renamed columns using withColumnRenamed() - changed total_amount to total_price. Then I renamed multiple columns at once by chaining withColumnRenamed() calls - changed total_amount to total_price, discount_percent to discount, and order_date to date.

For casting datatypes, I converted the quantity column from double to int since quantity should be a whole number, and converted order_date from string to date type using cast(). These are important because having the right datatypes helps with proper calculations and comparisons later.

I also added a new column called discount_price using withColumn() which was just total_amount multiplied by 0.9 (10% off). And I used lit() to replace an entire column with a constant value - I set all country values to "India" just to see how lit() works.

### Understanding Transformations vs Actions

I made a note of which PySpark operations are transformations (lazy - they dont execute immediately) and which are actions (they trigger actual computation).

Transformations I used: select(), filter(), withColumn(), withColumnRenamed(), orderBy(), dropDuplicates()

Actions I used: show(), count(), collect(), first(), take(), describe(), printSchema()

The key thing I learned here is that transformations are lazy - Spark just builds up a plan of what to do. Nothing actually runs until you call an action. So when I do df.filter(...).select(...), Spark doesnt do anything yet. Only when I call .show() or .count() does it actually execute everything.

I also tried collect() which brings all the data to the driver - used it to store all rows and access the 10th row specifically. Used first() to get the first row and take(5) to get the first 5 rows. For statistical summary, I used describe() on the numeric columns which gave me count, mean, stddev, min, and max values.

### Predicate Pushdown

This was an interesting concept. I filtered the data for Sports category and then used explain(True) to see the query execution plan. What I saw was that in the Physical Plan, the filter condition was pushed down to the scan level (PhotonScan). This means Spark doesnt read all the data and then filter - it actually applies the filter while reading from the parquet file itself. This is called predicate pushdown and its a big performance optimization, especially with parquet files since they store metadata about the data ranges in each file.

### Working with Different File Formats

I wrote the dataframe out as a CSV file and then read it back. Then I compared it with reading the same data from a parquet file. I checked the file sizes and read times:

- CSV read time: ~1.62 seconds
- Parquet read time: ~0.83 seconds

Parquet was almost 2x faster for reading. This makes sense because parquet is a columnar format with built-in compression and metadata, while CSV is just plain text that Spark has to parse line by line. Also with parquet, Spark doesnt need to infer the schema since its already embedded in the file.

I also compared using filter() vs SQL-style string expressions vs col() based filtering. All three gave the same results but its good to know the different syntax options available.

### Handling Null Values (Detailed)

This was the most involved part. I went column by column:

- email: Had 47 nulls. Filled them with "Not Provided" using na.fill() since we cant really derive email addresses.

- quantity: Had 41 nulls. I checked if I could calculate quantity from total_amount and unit_price (quantity = total_amount / unit_price), but turns out when quantity was null, total_amount was also null. So there was no way to derive it. I had to drop those rows using na.drop(subset=["quantity"]).

- discount_percent: Had 43 nulls. I was able to calculate this from unit_price and discount_price using the formula: (1 - discount_price / unit_price) * 100. Used when() and otherwise() to only fill where it was null and the other values were available.

- payment_method: Had 125 nulls which is a lot. Since theres no way to know what payment method was used, I filled it with "Unknown" using na.fill().

- rating: Had 53 nulls. This one was tricky because a null rating could mean the customer just didnt want to rate. So its actually a valid business scenario. But for analysis purposes I filled it with the average rating (rounded) using avg() function.

After all this handling, I verified that all columns had 0 null values. Then I saved the cleaned dataset as a new parquet file.

### Building a Data Pipeline

At the end I put everything together as a proper pipeline - read the raw parquet file, check nulls, handle all null values (email, quantity, payment_method, rating), filter the cleaned data for different scenarios like delivered orders only, electronics products, orders with discount > 10%, low rated delivered orders (rating <= 2), and delivered orders with discount >= 10%.

Finally I wrote the cleaned and processed data back out as a parquet file. This gave me a good understanding of the read → transform → filter → write pipeline pattern.

## Insights I Gained

Working through this assignment taught me quite a few things about PySpark and big data processing in general.

The biggest takeaway was understanding lazy evaluation. When I first started, I kept wondering why nothing was happening when I wrote filter or select statements. Then it clicked - Spark builds a DAG (directed acyclic graph) of operations and only executes when you trigger an action. This is actually smart because it lets Spark optimize the entire chain of operations before running anything.

Predicate pushdown was eye-opening. Seeing in the explain plan that Spark pushes the filter condition all the way down to the file scan level means it can skip reading irrelevant data entirely. This is why parquet + PySpark is such a good combo - parquet stores min/max values for each column in its metadata, so Spark can skip entire row groups that dont match the filter.

The null value handling part was where I spent the most time and learned the most. In real datasets, you cant just blindly drop or fill nulls. You have to think about each column - can you derive the value from other columns? Is a null actually meaningful (like a customer choosing not to rate)? What makes sense from a business perspective? For quantity, I couldnt derive it because total_amount was also null, so dropping was the only option. For discount_percent, I could calculate it from other available columns. For payment_method, "Unknown" was the best I could do.

The parquet vs CSV comparison was a practical lesson. Parquet being almost 2x faster for reads, having built-in schema, and being columnar makes it the obvious choice for analytical workloads. CSV is fine for interchange but not great for processing.

Overall this assignment gave me solid hands-on experience with PySpark DataFrame operations, data cleaning, and understanding how Spark optimizes query execution internally.
