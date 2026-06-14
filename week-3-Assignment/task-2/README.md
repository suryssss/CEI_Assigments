# Week 3 Assignment: Task 2 - Superstore SQL Analysis

## Summary
In this assignment, I continued working with the Superstore relational database. The objective was to apply intermediate and advanced SQL techniques including Subqueries, Common Table Expressions (CTEs), and Window Functions to analyze sales data and extract actionable business insights.

## Step 1: Setup Data
I imported the raw Superstore dataset into a staging table named `superstore_raw`. I then created the three core normalized tables: `customers`, `products`, and `orders`. I populated these tables by inserting distinct records from the raw dataset and performing essential data quality checks to identify duplicates and null values.

## Step 2: Perform Required Queries

**1. Orders Above Average Sales:** I used a subquery to find all orders where the sales amount is strictly greater than the overall average sales across the dataset.

**2. Highest Sales Order Per Customer:** I wrote a correlated subquery to determine the single highest-value order placed by each individual customer.

**3. Total Sales Per Customer:** I used a Common Table Expression (CTE) to calculate and aggregate the total sales for every customer.

**4. Customers Above Average Total Sales:** I combined a CTE and a subquery to identify high-value customers whose total sales exceed the overall average customer sales.

**5. Customer Ranking:** I used the `RANK()` window function to rank all customers globally based on their total sales volume.

**6. Order Row Numbers:** I used the `ROW_NUMBER()` window function combined with `PARTITION BY` to assign sequential row numbers to each order within a specific customer's purchase history.

**7. Top 3 Customers:** I used a window function wrapped inside a CTE to identify and display the top 3 spending customers overall.

## Step 3: Final Combined Query
I wrote a  query utilizing a CTE to compute sales, a `JOIN` to link customer details, and a Window Function (`RANK()`) to display the Customer Name, Total Sales, and their global Sales Rank side-by-side.

## Mini Project: Customer Sales Insights
I answered several specific business questions using SQL aggregations and subqueries:
- Identified the top 5 customers and bottom 5 customers by total sales.
- Found customers who have only made exactly one order.
- Identified customers performing above the average sales threshold.
- Retrieved the highest single order value achieved by each customer.

## Tools Used
- MySQL 8.0.x
- MySQL Workbench 
- Superstore transaction dataset
