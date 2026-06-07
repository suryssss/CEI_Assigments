# Week 2 Data Engineering Assignment — ShopEase E-Commerce SQL Analysis

## Summary
In this assignment, I worked with a relational database for ShopEase, a mid-sized e-commerce company that sells electronics, clothing, and home products across India. The goal was to write SQL queries to extract meaningful insights about sales patterns, customer behavior, and product performance. The database has 4 tables — customers (8 records), products (8 records), orders (10 records), and order_items (15 records) — connected through foreign key relationships.

## Database Setup
I created a database called `shopease` in MySQL and set up all 4 tables with proper constraints including primary keys, foreign keys, CHECK constraints, UNIQUE, NOT NULL, and DEFAULT values. I also created indexes on commonly filtered columns like city, state, category, order_date, and status to improve query performance. After creating the tables, I loaded the sample data using INSERT statements and verified each table using `select *` and `count(*)` queries.

## Section A — SQL Basics (Q1–Q6)

**Q1.** I wrote `select * from customers` to display all columns and rows from the customers table. This returned all 8 customer records with their details.

**Q2.** I retrieved only the first_name, last_name, and city columns from the customers table using `select first_name, last_name, city from customers`.

**Q3.** I used `select distinct category from products` to list all unique categories. The products table has 3 categories — Electronics, Clothing, and Home.

**Q4.** I identified the primary key of each table using `show create table`. The primary keys are customer_id (customers), product_id (products), order_id (orders), and item_id (order_items). A primary key must be unique because it identifies each row, and it cannot be null because the database needs a value to locate the record.

**Q5.** The email column in the customers table has two constraints — UNIQUE and NOT NULL. I tested the UNIQUE constraint by inserting a duplicate email which gave the error "Duplicate entry for key customers.email". I also tested the NOT NULL constraint by passing NULL for email which gave "Column 'email' cannot be null".

**Q6.** I tried inserting a product with unit_price = -50 using `insert into products values (209,'USB Cable','Electronics','Mi',-50.00,100)`. The CHECK constraint `check(unit_price > 0)` prevented this and gave the error "Check constraint products_chk_1 is violated".

## Section B — Filtering and Optimization (Q7–Q12)

**Q7.** I retrieved all delivered orders using `select * from orders where status = 'Delivered'`. This returned 6 orders.

**Q8.** I filtered products in the Electronics category with unit_price greater than 2000 using `where category = 'Electronics' and unit_price > 2000`. This returned the Smart Watch (2999) and Bluetooth Speaker (3499).

**Q9.** I listed customers who joined in 2024 and belong to Maharashtra using `where state = 'Maharashtra' and join_date between '2024-01-01' and '2024-12-31'`. I used a date range instead of `year()` to keep the query index-friendly.

**Q10.** I found orders placed between 2024-08-10 and 2024-08-25 that are not cancelled using `where order_date between '2024-08-10' and '2024-08-25' and not status = 'Cancelled'`.

**Q11.** I explained how the `idx_orders_date` index works like a book index — it helps the database jump directly to matching rows instead of scanning every row. I wrote a sample query `select * from orders where order_date = '2024-08-15'` that benefits from this index because it filters directly on the indexed column.

**Q12.** I explained that `select * from customers where year(join_date) = 2024` would not use the index on join_date because the `year()` function is applied to every row before comparison, which prevents the database from using the index. I rewrote it as `where join_date between '2024-01-01' and '2024-12-31'` which is the SARGable (index-friendly) version.

## Section C — Aggregation (Q13–Q18)

**Q13.** I counted the total number of orders using `select count(*) as total_orders from orders`. The table has 10 orders.

**Q14.** I calculated the total revenue from delivered orders using `select sum(total_amount) from orders where status = 'Delivered'`.

**Q15.** I found the average unit_price of products in each category using `round(avg(unit_price), 2)` with `group by category`.

**Q16.** I grouped orders by status and calculated the count and total revenue for each status using `count(*)` and `sum(total_amount)`, sorted by total revenue in descending order. Delivered orders had the highest total revenue.

**Q17.** I found the most expensive and cheapest product in each category using `max(unit_price)` and `min(unit_price)` with `group by category`.

**Q18.** I used the HAVING clause to filter categories where the average unit_price is greater than 2000. Only the Electronics category met this condition since it has products like the Smart Watch and Bluetooth Speaker.

## Section D — Joins and Relationships (Q19–Q23)

**Q19.** I wrote an INNER JOIN between orders and customers to display each order with the customer's first_name and last_name. I used table aliases (`o` for orders, `c` for customers) and joined on `o.customer_id = c.customer_id`.

**Q20.** I used a LEFT JOIN to list all customers and their orders. Customers without any orders still appeared in the results with NULL values for the order columns. This is useful to identify inactive customers.

**Q21.** I wrote a three-table JOIN query joining orders → order_items → products to show order_id, product_name, quantity, unit_price, and discount_pct for each order item. I used two INNER JOINs chained together.

**Q22.** I explained the difference between LEFT JOIN and RIGHT JOIN with examples. LEFT JOIN returns all customers and their matching orders, so customers without orders still appear. RIGHT JOIN returns all orders and their matching customers, so orders without matching customers (if any) would still appear. I also noted that MySQL does not support FULL OUTER JOIN directly, but it can be achieved using a UNION of LEFT JOIN and RIGHT JOIN. A FULL OUTER JOIN would show both customers without orders and orders without customers.

**Q23.** I identified all three foreign key relationships — orders.customer_id references customers.customer_id, order_items.order_id references orders.order_id, and order_items.product_id references products.product_id. I tested inserting an order with customer_id = 999 which failed with the error "Cannot add or update a child row: a foreign key constraint fails". This shows that foreign keys prevent invalid records and maintain consistency between tables.

## Section E — Advanced Concepts (Q24–Q27)

**Q24.** I used a CASE statement to classify products into price tiers — Budget (unit_price below 1000), Mid-Range (between 1000 and 3000), and Premium (above 3000). Products like Laptop Stand and Cushion Covers fell under Budget, Wireless Earbuds and Smart Watch under Mid-Range, and Running Shoes under Premium.

**Q25.** I used CASE inside an aggregate function to count delivered vs not delivered orders in a single row. I used `sum(case when status = 'Delivered' then 1 else 0 end)` for delivered orders and the opposite condition for not delivered orders.

**Q26.** I explained each ACID property with bank transfer examples. Atomicity means a transaction is all-or-nothing — if deducting from one account succeeds but adding to another fails, the whole thing rolls back. Consistency means the total money stays the same before and after a transfer. Isolation means two users withdrawing from the same account at the same time do not interfere with each other. Durability means once a transfer is committed, the data is permanently saved even if the system crashes.

**Q27.** I wrote a complete transaction block using `start transaction` and `commit`. The transaction inserts a new order (order_id 1011 for customer 102), adds two order items (products 206 and 208), and updates the stock_qty for both products. If any step fails, the entire transaction can be rolled back to maintain data integrity.

## Tools Used
- MySQL 8.0.46
- MySQL Workbench (for query execution)
- Sample data provided in the assignment (4 tables, 41 total records)

## Conclusion
Through this assignment, I learned how to design and set up a relational database with proper constraints and indexes, write basic SELECT queries with column selection and filtering, use WHERE clauses with various operators including BETWEEN and IN, understand how indexes improve query performance and what makes a query SARGable, use aggregate functions (SUM, COUNT, AVG, MIN, MAX) with GROUP BY and HAVING, combine data from multiple tables using INNER JOIN, LEFT JOIN, and multi-table JOINs, use CASE statements for conditional logic both standalone and inside aggregates, understand ACID properties and their importance in database transactions, and write transaction blocks with START TRANSACTION, COMMIT, and ROLLBACK for atomic operations.
