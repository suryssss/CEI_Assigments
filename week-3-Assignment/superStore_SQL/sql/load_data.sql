-- superstore_raw was imported via MySQL Workbench Table Data Import Wizard,


-- inserting distinct records into customers
insert into customers
select distinct
    `customer id`,
    `customer name`,
    segment
from superstore_raw;

select count(*) from customers;



-- inserting distinct record into products table
insert into products
select distinct
    `Product ID`,
	Category,
    `Sub-Category`,
    `Product Name`
from superstore_raw;

select count(*) from products ;


-- inserting into order table
insert into orders
select 
    `row id`,
    `order id`,
    `order date`,
    `ship date`,
    `ship mode`,
    `customer id`,
    `product id`,
    `country`,
    `city`,
    `state`,
    `postal code`,
    `region`,
    `sales`,
    `quantity`,
    `discount`,
    `profit`
from superstore_raw;

select count(*) from orders;

-- data quality checks 

-- 1 . to check for duplicates
select customer_id,count(*)
from customers
group by customer_id
having count(*)>1;

-- 2 checking for null values
select * from orders
where customer_id is null
or product_id is null;

-- 3 date validation 
select * from orders
where ship_date<order_date;