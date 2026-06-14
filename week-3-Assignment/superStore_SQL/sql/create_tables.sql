create database superstore_data;
use superstore_data;


-- data is imported through table data import wizard
select count(*) from superstore_raw;
Describe superstore_raw;

-- creating customers table 
create table customers(
	customer_id varchar(50) Primary key,
    customer_name varchar(100),
    segment varchar(50)
);


-- product_id is NOT a primary key because the Superstore dataset
-- contains duplicate product_id mapped to different product names.


-- creating products table 
create table products (
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255)
);

-- creating orders table
create table orders (
    row_id INT primary key,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),

    customer_id VARCHAR(50),
    product_id VARCHAR(50),

    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),

    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2),

    foreign key  (customer_id)
        references customers(customer_id)
);