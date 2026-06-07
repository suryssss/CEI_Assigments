create database shopease;

use shopease;

create table customers(
	customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    join_date DATE NOT NULL,
    is_premium BOOLEAN DEFAULT FALSE
);

create index idx_customers_city ON customers(city); 
create index idx_customers_state ON customers(state);

create table products ( 
    product_id    INT           PRIMARY KEY, 
    product_name  VARCHAR(100)  NOT NULL, 
    category      VARCHAR(50)   NOT NULL, 
    brand         VARCHAR(50)   NOT NULL, 
    unit_price    DECIMAL(10,2) NOT NULL  CHECK (unit_price > 0), 
    stock_qty     INT           NOT NULL  DEFAULT 0  CHECK (stock_qty >= 0) 
);

-- Index for filtering by category 
create index idx_products_category ON products(category);

create table orders ( 
    order_id      INT           PRIMARY KEY, 
    customer_id   INT           NOT NULL, 
    order_date    DATE          NOT NULL, 
    status        VARCHAR(20)   NOT NULL  DEFAULT 'Pending' 
                  CHECK (status IN ('Pending','Shipped','Delivered','Cancelled')), 
    total_amount  DECIMAL(12,2) NOT NULL  CHECK (total_amount >= 0), 
     
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
); 

-- Index for date-based filtering and sorting 
create index idx_orders_date ON orders(order_date); 
create index idx_orders_status ON orders(status);

create table order_items ( 
    item_id       INT           PRIMARY KEY, 
    order_id      INT           NOT NULL, 
    product_id    INT           NOT NULL, 
    quantity      INT           NOT NULL  CHECK (quantity > 0), 
    unit_price    DECIMAL(10,2) NOT NULL  CHECK (unit_price > 0), 
    discount_pct  DECIMAL(5,2)  DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100), 
     
    FOREIGN KEY (order_id)   REFERENCES orders(order_id), 
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
); 

show tables;

describe customers;
describe products;
describe orders;
describe order_items;


-- ========== INSERT: customers ========== 
insert into customers values
(101, 'Aarav',  'Sharma', 'aarav.s@email.com',  'Mumbai',    'Maharashtra', '2024-01-15', TRUE), 
(102, 'Priya',  'Patel',  'priya.p@email.com',  'Ahmedabad', 'Gujarat',     '2024-02-20', FALSE), 
(103, 'Rohan',  'Gupta',  'rohan.g@email.com',  'Delhi',     'Delhi',       '2024-03-10', TRUE), 
(104, 'Sneha',  'Reddy',  'sneha.r@email.com',  'Hyderabad', 'Telangana',   '2024-04-05', FALSE), 
(105, 'Vikram', 'Singh',  'vikram.s@email.com', 'Jaipur',    'Rajasthan',   '2024-05-12', TRUE), 
(106, 'Ananya', 'Iyer',   'ananya.i@email.com', 'Chennai',   'Tamil Nadu',  '2024-06-18', FALSE), 
(107, 'Karan',  'Mehta',  'karan.m@email.com',  'Pune',      'Maharashtra', '2024-07-22', TRUE), 
(108, 'Divya',  'Nair',   'divya.n@email.com',  'Kochi',     'Kerala',      '2024-08-30', FALSE); 

-- loading data
select * from customers;

-- ========== INSERT: products ========== 
insert into products values
(201, 'Wireless Earbuds',     'Electronics', 'BoAt',          1499.00, 250), 
(202, 'Cotton T-Shirt',       'Clothing',    'Levis',         799.00,  500), 
(203, 'Smart Watch',          'Electronics', 'Noise',         2999.00, 150), 
(204, 'Running Shoes',        'Clothing',    'Nike',          4599.00, 120), 
(205, 'Bluetooth Speaker',    'Electronics', 'JBL',           3499.00, 200), 
(206, 'Bedsheet Set',         'Home',        'Spaces',        1299.00, 300), 
(207, 'Laptop Stand',         'Electronics', 'AmazonBasics',  899.00,  180), 
(208, 'Cushion Covers (Set)', 'Home',        'HomeCenter',    599.00,  400); 

-- loading data
select * from products;

-- ========== INSERT: orders ========== 
insert into orders values
(1001, 101, '2024-08-01', 'Delivered',  4498.00), 
(1002, 102, '2024-08-03', 'Delivered',  799.00), 
(1003, 103, '2024-08-05', 'Shipped',    7498.00), 
(1004, 101, '2024-08-10', 'Delivered',  3499.00), 
(1005, 104, '2024-08-12', 'Cancelled',  2999.00), 
(1006, 105, '2024-08-15', 'Delivered',  5898.00), 
(1007, 106, '2024-08-18', 'Pending',    1299.00), 
(1008, 103, '2024-08-20', 'Delivered',  899.00), 
(1009, 107, '2024-08-25', 'Shipped',    6098.00), 
(1010, 108, '2024-08-28', 'Delivered',  1598.00); 

-- loading data
select * from orders;

-- ========== INSERT: order_items ========== 
insert into order_items values
(5001, 1001, 201, 2, 1499.00, 0), 
(5002, 1001, 207, 1, 899.00,  10), 
(5003, 1002, 202, 1, 799.00,  0), 
(5004, 1003, 203, 1, 2999.00, 0), 
(5005, 1003, 204, 1, 4599.00, 5), 
(5006, 1004, 205, 1, 3499.00, 0), 
(5007, 1005, 203, 1, 2999.00, 0), 
(5008, 1006, 201, 1, 1499.00, 10), 
(5009, 1006, 204, 1, 4599.00, 5), 
(5010, 1007, 206, 1, 1299.00, 0), 
(5011, 1008, 207, 1, 899.00,  0), 
(5012, 1009, 205, 1, 3499.00, 0), 
(5013, 1009, 208, 2, 599.00,  15), 
(5014, 1010, 206, 1, 1299.00, 0), 
(5015, 1010, 208, 1, 599.00,  0); 

-- loading data
select * from order_items;

-- verifying the counts
select count(*) from customers;
select count(*) from products;
select count(*) from orders;
select count(*) from order_items;


-- SECTION A -SQL BASICS(SELECT, Constraints, Primary Keys)

-- 1 Write a query to display all columns and rows from the customer's table. 
select * from customers;

-- 2 Retrieve only the first_name, last_name, and city of all customers. 
select first_name,last_name,city from customers;

-- 3 List all unique categories available in the products table.
select distinct category from products;

-- 4 Identify the Primary Key of each table in the schema. Explain why a Primary Key must be unique and NOT NULL.
show create table customers;
show create table products;
show create table orders;
show create table order_items;

/* 
 The primary keys in the each table are 
 customers table - customer_id
 products table - products_id
 orders table - order_id 
 order_items table - item_id
 
 
 a primary key must be unqiue because it uniquely identifies each row 
 example:
	customer_id=201 this id refers only to a single customer not others could have this id.

a null value means an unknown value where there is not value exsits for the row
the database cannot identify the record if there primary key is null as the primary key is the
only unique key that helps to identify a particular row 
example 
	customer_id     first_name
    null			aarav
for this the database cannot uniquely identify this record

so due to these reasons the primary key in the database should always be unique and not null

*/

-- 5 What constraints are applied to the email column in the customers table? What would happen if you tried to 
-- insert a duplicate email?

show create table customers;

/* 

there are two constraints applied on email column in customers table
as email varchar(100) unique not null 
*/
 
 insert into customers values (109,'Rithwik','Kumar','aarav.s@email.com','Hyderabad','Telangana','2026-06-06',TRUE);

/*
the two constrains are applied 
because email is always a unqiue value ie no two
people could have same email so the constraint unqiue prevents duplicate emails from 
being stored into the database 

if u try to insert duplicate emails you get an error as 
Duplicate entry 'aarav.s@email.com' for key 'customers.email'
*/

insert into customers values (109,'Rithwik','Kumar', NULL, 'Hyderabad','Telangana','2026-06-06',TRUE);


/*
not null ensures every customer has an email address such that every customer 
must provide an email 
if any data inserted with email as null we get an error as 

Column 'email' cannot be null

*/

-- 6 Try inserting a product with unit_price = -50. What happens and which constraint prevents it? 
-- Write both the INSERT statement and explain the error

insert into products values (209,'USB Cable','Electronics','Mi',-50.00,100);

/* 
 when i try to insert the product with unit_price -50 the database gives and error as
 Check constraint product_chk_1 is violated
 because 
 in the table defination 
 it is mentioned as check(unit_price>0)
 that includes that the unit_price cannot be negative and must positive 
 so this constraint ensures that the unit price must be grearer than 0 
 anything above is valid but less than 0 will be invalid and databse throws an error
*/

-- SECTION B Filtering & Optimization (WHERE, Indexes)

-- 7 Retrieve all orders with status = 'Delivered'.
select * from orders where status ='Delivered';

-- 8 Find all products in the 'Electronics' category with a unit_price greater than ₹2000.
select * from products 
where category='Electronics'
and unit_price>2000;

-- 9 List all customers who joined in the year 2024 and belong to the state 'Maharashtra'. 
select * from customers
where state='Maharashtra'
and join_date between'2024-01-01' and '2024-12-31';

-- 10 Find all orders placed between '2024-08-10' and '2024-08-25' (inclusive) that are NOT cancelled.
select * from orders
where order_date between '2024-08-10' and '2024-08-25'
and not status ='Cancelled';

-- 11 Explain what the index idx_orders_date does. How would it improve the performance of a query that filters 
-- orders by order_date? Write a sample query that would benefit from this index.
-- note: idx_orders_date was already created at line 43 during table setup

/* 
 an index works like a index in a book i.e it using index in a book we directly find the page that we need 
 in the similar way the index in database helps to directly jump to matching dates 
 without and index the database scans every row which takes lot of time so to reduce time to run query 
 we use indexing
 example query
 
 */
 select * from orders where order_date='2024-08-15';
 /*
 here the order_date is index hence sql locate the matching rows much faster than without using index
 so overall the indexing improve the perfomance of filtering sorting and range searches that involves that
 in the database
*/

-- 12  If you run: SELECT * FROM customers WHERE YEAR(join_date) = 2024; — would the index on join_date be used? 
-- Explain why or why not, and rewrite the query to be index-friendly (SARGable). 
select * from customers where year(join_date)=2024;

/*
 no by running the above query the index on the join_date cannot be used 
 we all know the flow of sql where in the above query first it calculates year(join_date)
 for every row
 
 the index stores the date in yyyy-mm-dd format 
 not in the yyyy format 
the year function is being applied to every row before comparsion so it cant be used as index
a better approch would be to use date range allowing the databse to use join_date index
*/

select * from customers where join_date
between '2024-01-01' and '2024-12-31';

/* 
the above is the index friendly version 
*/


-- Section C — Aggregation (GROUP BY, SUM, COUNT, AVG, MIN, MAX) 

-- 13 Count the total number of orders in the orders table.
select count(*) as total_orders from orders;


-- 14 Find the total revenue (SUM of total_amount) from all 'Delivered' orders. 
select sum(total_amount) as total_revenue from orders
where status='Delivered';

-- 15 Calculate the average unit_price of products in each category. 
select category,round(avg(unit_price),2) as avg_price
from products 
group by category;

-- 16 For each order status, find the count of orders and the total revenue. 
-- Sort the result by total revenue in descending order.
select status, count(*) as order_count,
	sum(total_amount) as total_revenue
from orders
group by status
order by total_revenue desc;

-- 17 Find the most expensive (MAX) and cheapest (MIN) product in each category.
select category,max(unit_price) as most_expensive,
	min(unit_price) as cheapest
from products
group by category;

-- 18 List all product categories where the average unit_price is greater than ₹2000. (Hint: Use HAVING clause)
select category,
    round(avg(unit_price),2) as avg_price
from products 
group by category
having avg(unit_price)>2000;

-- Section D — Joins & Relationships 

-- 19 Write an INNER JOIN query to display each order along with the customer's first_name 
-- and last_name. Show: order_id, order_date, first_name, last_name, total_amount.
 
 select 
	o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    o.total_amount
from orders o 
inner join customers c 
on o.customer_id= c.customer_id;


-- 20 Using a LEFT JOIN, list ALL customers and their orders (if any). 
-- Customers with no orders should still appear with NULL values for order columns.

select 
    c.customer_id,
    c.first_name,
    c.last_name,
    o.order_id,
    o.order_date,
    o.status
from customers c
left join orders o 
on c.customer_id = o.customer_id;

-- 21 Write a query using JOINs across three tables (orders → order_items → products) 
-- to show: order_id, product_name, quantity, unit_price, and discount_pct for each order item.
select 
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount_pct
from orders o 
inner join order_items oi 
	on o.order_id=oi.order_id
inner join products p 
	on oi.product_id=p.product_id;
    
-- 22 Explain the difference between LEFT JOIN and RIGHT JOIN with an example from this schema.
--  When would you use a FULL OUTER JOIN?

-- LEFT JOIN
select * from customers c 
left join orders o 
on c.customer_id = o.customer_id;

/* 
the left joins return all customers in left table  and matching orders in right table 
i.e the customers without orders will be seen in the table 
*/
 
 -- RIGHT JOIN
 select * from customers c 
 right join orders o
 on c.customer_id=o.customer_id;
 /* 
 the right join return all the orders in right table and matching customers in left table 
 */
 
 -- FULL OUTER JOIN 
 /* 
 mysql isnt supporting full outer join to exectue the query 
 
 but full outer join =left join+right join+union 
 the full outer join display rows from both tables
 when i run query of full outer join for customers and orders i get 
 customers without orders 
 orders without customers 
 and matching records 
 */
 
 
-- 23 Identify all Foreign Key relationships in the schema. Explain what would happen if you tried to insert an order
-- with customer_id = 999 (which doesn't exist in customers).

 /* 
 a foregin key is a column in a table that refers to primary key of another table
 foregin key relationships
 orders.customer_id - customers.customer_id
 order_items.order_id - orders.order_id
 order_items.product_id - products.product_id
 
 there foregin keys establish the relations between the tables
 
 */
 /*
 example inserting an order with customer id=999
 */
 insert into orders values (1011,999,'2024-09-01','Pending',1000.00);
  /* 
  when i run this query i got an errors as cannot add or update a child row a foregin key constraint fail 
  i.e foreign keys prevent invalid records from being created and maintain consistency between the tables
  so the an order cannot be inserted for customer that doesnt exists in customers tab;e
  */
  
  -- Section E — Advanced Concepts (CASE, ACID, Transactions) 
  
  /* 
24  Write a query using CASE to classify products into price tiers: 
  • 'Budget'    → unit_price < 1000 
  • 'Mid-Range' → unit_price BETWEEN 1000 AND 3000 
  • 'Premium'   → unit_price > 3000 
Display: product_name, unit_price, price_tier.
  */
  
select product_name,
	unit_price,
    case 
		when unit_price <1000 then 'budget'
        when unit_price between 1000 and 3000 then 'mid-range'
        when unit_price >3000 then 'premium'
	end as price_tier
from products;
        
        
-- 25Using a CASE statement inside an aggregate function, count how many orders are 'Delivered' vs 'Not Delivered' 
-- (all other statuses). Display the result in a single row.
select sum(case
            when status = 'Delivered' then 1
            else 0
        end) as delivered_orders,
		sum(case
            when status <> 'Delivered' then 1
            else 0
		end) as not_delivered_orders
from orders;

  
  /* 
  26  Explain each letter of ACID: 
  • A – Atomicity 
  • C – Consistency 
  • I – Isolation 
  • D – Durability 
Give a real-world example (e.g., bank transfer) showing why each property is important.
  */
 
 /*
 ACID - a set of properties that ensure database transactions are processed reliably and maintain data
 consistency
 
 A-Atomicity
 A transaction is treated as a single unit of work.
 Either all operations succeed or none of them are executed
 
 example bank transfer 
 
suppose 1000 is transferred from account a to account b 
Step 1: Deduct ₹1000 from Account A
Step 2: Add ₹1000 to Account B

if Step 1 succeeds but Step 2 fails, the entire transaction is rolled back.

so it prevents partial updates and loss of money because of this it is important

C – Consistency
A transaction must take the database from one valid state to another valid state 
while obeying all constraints and rules.

example

Account A = ₹5000
Account B = ₹3000
Total = ₹8000

After transferring ₹1000:

Account A = ₹4000
Account B = ₹4000
Total = ₹8000

the total money will be consistent 

it is important business rules and constraints are never violated

I – Isolation
Multiple transactions running at the same time should not interfere with each other

example 
Two users simultaneously try to withdraw money from the same account.
The database isolates the transactions so that one transaction does not 
see incomplete changes made by another

it prevents data corruption adn incorrect balances

D – Durability
Once a transaction is committed, the changes are permanently saved, even if the system crashes.

example 
After a successful transfer, the bank server crashes.
When the system restarts, the transfer is still recorded because the 
committed data was permanently stored.

it ensures commited data is never lost
 */
 
/* 
27  Write a SQL transaction that does the following atomically: 
  1. Insert a new order (order_id=1011, customer_id=102, today's date, 'Pending', 1598.00) 
  2. Insert two order items for that order 
  3. Update the stock_qty of the purchased products 
  4. If any step fails, ROLLBACK the entire transaction. Otherwise, COMMIT. 
Write the complete BEGIN...COMMIT/ROLLBACK block. 
*/

-- mysql transaction 

start transaction;

-- step 1: insert new order
insert into orders(order_id, customer_id, order_date, status, total_amount)
values(1011, 102, curdate(), 'Pending', 1598.00);

-- step 2: insert first order item
insert into order_items(item_id, order_id, product_id, quantity, unit_price, discount_pct)
values(5016, 1011, 206, 1, 1299.00, 0);

-- insert second order item
insert into order_items(item_id, order_id, product_id, quantity, unit_price, discount_pct)
values(5017, 1011, 208, 1, 599.00, 0);

-- step 3: update stock for product 206
update products set stock_qty = stock_qty - 1
where product_id = 206;

-- update stock for product 208
update products set stock_qty = stock_qty - 1
where product_id = 208;

-- step 4: if everything succeeds commit otherwise rollback
commit;
-- if any step fails run: rollback;