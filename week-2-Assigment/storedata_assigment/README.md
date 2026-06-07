# Week 2 Data Engineering Assignment

## Summary
In this assignment, I worked with the Superstore Sales dataset from Kaggle using SQL (MySQL). The goal was to analyze sales data using filtering, aggregation, and business queries. The dataset contains 9,994 transaction records with 21 columns covering order details, customer information, product categories, sales, profit, discounts, and shipping information.

## Load Dataset into SQL Database
I loaded the CSV file into MySQL using the Table Data Import Wizard in MySQL Workbench. A database called `sales_analysis` was created and the data was imported into a table named `storedata`. The table has 21 columns including order details (`order id`, `order date`, `ship date`, `ship mode`), customer information (`customer id`, `customer name`, `segment`), location data (`city`, `state`, `region`), and product/transaction details (`category`, `sub-category`, `sales`, `quantity`, `discount`, `profit`).

## Explore the Dataset
I explored the table using `describe` to check the schema and `select * limit 10` to view sample data. The dataset has 9,994 records with 793 unique customers, 1,862 unique products, and 5,009 unique orders. There are 4 regions (East, West, South, Central), 3 categories (Furniture, Office Supplies, Technology), 17 sub-categories, and 3 customer segments (Consumer, Corporate, Home Office).

## Apply WHERE Filters
I applied various filters to explore different subsets of the data. I filtered by revenue thresholds (sales above 500 and 1000), profitability (loss-making orders, high profit orders, break-even orders), and discount levels (no discount, discounted, heavy discount). I also filtered by customer segment, region, product category, date range (2017 orders), and shipping mode.

Some interesting findings from the filters: there are orders with high revenue but negative profit, which indicates that heavy discounts are eating into margins. I also found transactions with high quantity but very low revenue, and orders with losses exceeding 100. Combining the discount and profit filters showed that discounted orders are more likely to result in losses.

## GROUP BY Aggregations
I used `group by` with aggregate functions to summarize the data. I calculated total sales and profit by region, category, sub-category, and customer segment. I also computed average sales and average profit by category, and found the min and max sales values for each category.

From the aggregations, I observed that the West region has the highest total sales followed by East. Technology category has the highest average sales per transaction, while Office Supplies has the most transactions but lower average values. I also created combined aggregations showing total sales, quantity, and profit together by category and region.

## Sort and Limit Results
I used `order by` and `limit` to find top-performing and bottom-performing items. I identified the top 10 transactions by sales and profit, the top 10 products, customers, states, and cities by sales. I also found the most loss-making orders and transactions.

The top customers by sales and by profit are not always the same, which shows that high revenue does not always mean high profit. I also looked at customers by number of orders using `count(distinct)` to find the most frequent buyers.

## Use Cases
I solved three main use cases from the assignment:

**Monthly Trends:** I used `str_to_date()` and `date_format()` to extract month from the order date and tracked monthly sales, order count, and profit trends. The data spans from 2014 to 2017, and there is a clear seasonal pattern with sales peaking towards the end of each year.

**Top Customers:** I identified the top 10 customers by sales, profit, and number of orders. This helps in understanding which customers drive the most value for the business.

**Duplicate Check:** I checked for duplicate records using `group by` with `having count(*) > 1`. Orders with multiple entries are not duplicates — they represent multi-item orders where the same order id has different products. I also checked for exact duplicates on the combination of order id, customer id, and product id.

## Validate Results
I performed data quality checks by looking for null values across all key columns including customer id, order id, product id, sales, profit, quantity, and region. I also checked for negative sales values and invalid discount values (less than 0 or greater than 1).

The dataset is clean with no null values in any critical column and no invalid entries. I created a comprehensive null value summary query that checks all important columns in a single query for quick validation.

## Tools Used
- MySQL 8.0.46
- MySQL Workbench (for data import and query execution)
- Dataset: Superstore Sales from Kaggle (9,994 rows, 21 columns)

## Conclusion
Through this assignment, I gained hands-on experience with SQL for data analysis. I learned how to explore datasets using schema inspection and distinct value counts, filter data using `where` with various conditions and operators (`between`, `in`, `and`, `or`), aggregate data using `group by` with functions like `sum()`, `avg()`, `min()`, `max()`, and `count()`, sort and limit results to find top-N items, work with date strings using `str_to_date()` and `date_format()`, detect duplicates using `having`, and validate data quality through null checks and boundary validation. These are essential skills for querying and analyzing data in real-world data engineering workflows.
