-- celebal technologies week-2 assigment

-- 1 data loading 
-- The storedata.csv was imported using mysql workbench tables data import wizard

-- the table schema is 
create table if not exists storedata (
    `row id`        int,
    `order id`      varchar(20),
    `order date`    varchar(20),
    `ship date`     varchar(20),
    `ship mode`     varchar(20),
    `customer id`   varchar(10),
    `customer name`  varchar(50),
    segment         varchar(20),
    country         varchar(30),
    city            varchar(40),
    state           varchar(30),
    `postal code`   int,
    region          varchar(10),
    `product id`    varchar(20),
    category        varchar(20),
    `sub-category`  varchar(20),
    `product name`  varchar(200),
    sales           decimal(10,4),
    quantity        int,
    discount        decimal(4,2),
    profit          decimal(10,4)
); 

-- creating the database
create database sales_analysis;

-- use database
use sales_analysis;


-- data exploration (schema,sample)

-- schema of the data
describe storedata;

-- display sample data from storedata
select * from storedata limit 10;

-- total records
select count(*) as total_records from storedata;


-- distinct value analysis

-- distinct customer ids
select count(distinct `customer id`) as customers from storedata;

-- distinct product ids
select count(distinct `product id`) as products from storedata;

-- distinct order ids
select count(distinct `order id`) as orders from storedata;

-- unique values per each column
select
    count(distinct region) region_cnt,
    count(distinct category) category_cnt,
    count(distinct `sub-category`) subcategory_cnt,
    count(distinct segment) segment_cnt
from storedata;

-- check categorries
select distinct region from storedata;

-- check categories
select distinct category from storedata;

-- check sub-categories
select distinct `sub-category` from storedata;

-- check segment 
select distinct segment from storedata;

-- where filter(region,category,data,sales)

-- revenue exploration

-- high revenue orders
select * from storedata where sales > 500;

-- very high revenue orders
select * from storedata where sales > 1000;

-- low revenue orders
select * from storedata where sales < 50;

-- profitability exploration

-- loss making orders
select * from storedata where profit < 0;

-- high profit orders
select * from storedata where profit > 1000;

-- break-even orders
select * from storedata where profit = 0;

-- discount analysis

-- no discount orders
select * from storedata where discount = 0;

-- discounted orders
select * from storedata where discount > 0;

-- huge discount orders
select * from storedata where discount >= 0.4;

-- heavy discount and loss
select * from storedata where discount > 0 and profit < 0;

-- customer details

-- consumer segment
select * from storedata where segment = 'Consumer';

-- corporate segment
select * from storedata where segment = 'Corporate';

-- home office segment
select * from storedata where segment = 'Home Office';

-- regional filter

-- west region
select * from storedata where region = 'West';

-- multiple regions 
select * from storedata where region in ('West','South');

-- product filter

-- technology orders
select * from storedata where category = 'Technology';

-- office supplies
select * from storedata where category = 'Office Supplies';

-- phone subcategory
select * from storedata where `sub-category` = 'Phones';

-- date filter

-- orders in 2017
select * from storedata where str_to_date(`order date`, '%m/%d/%Y') between '2017-01-01' and '2017-12-31';

-- shipping filter

-- same day delivary
select * from storedata where `ship mode` = 'Same Day';

-- standard class
select * from storedata where `ship mode` = 'Standard Class';

-- checing for any empty values 

-- null customer id 
select * from storedata where `customer id` is null;

-- high revenue but loss making 
select * from storedata where sales > 500 and profit < 0;

-- high quantity low revenue
select * from storedata where quantity >= 10 and sales < 100;

-- worst transactions
select * from storedata where profit < -100;



-- group by aggregations

-- total sales by region 
select region, round(sum(sales), 2) as total_sales
from storedata group by region
order by total_sales desc;

-- total sales by category
select category, round(sum(sales), 2) as total_sales
from storedata group by category
order by total_sales desc;

-- total sales by sub category
select `sub-category`, round(sum(sales), 2) as total_sales
from storedata group by `sub-category`
order by total_sales desc;

-- total quantity by region
select region, sum(quantity) as total_quantity
from storedata group by region
order by total_quantity desc;

-- average sales by category
select category, round(avg(sales), 2) as avg_sales
from storedata group by category
order by avg_sales desc;

-- average profit by category
select category, round(avg(profit), 2) as avg_profit
from storedata group by category
order by avg_profit desc;

-- sales by customer segment
select segment, round(sum(sales), 2) as total_sales
from storedata
group by segment
order by total_sales desc;

-- min and max sales by category
select category, max(sales) as max_sales, min(sales) as min_sales 
from storedata
group by category;

-- total sales,quantity and profit by category
select category,
	round(sum(sales), 2) as total_sales,
    sum(quantity) as total_quantity,
    round(sum(profit), 2) as total_profit
from storedata
group by category
order by total_sales desc;

-- total sales and profit by region 
select region,
	round(sum(sales), 2) as total_sales,
    round(sum(profit), 2) as total_profit
from storedata
group by region
order by total_sales desc;


-- 5 sort and and limit 

-- top 10 highest sales transactions
select * from storedata 
order by sales desc
limit 10;

-- top 10 highest profit transactions
select * from storedata 
order by profit desc
limit 10;

-- top 10 loss transactions
select * from storedata
order by profit asc 
limit 10;

-- top 10 prodcuts by sales;
select `product name`,
	round(sum(sales), 2) as total_sales
from storedata
group by `product name`
order by total_sales desc
limit 10;

-- top 10 orders by profit
select
    `order id`,
    round(sum(profit), 2) as total_profit
from storedata
group by `order id`
order by total_profit desc
limit 10;

-- top 10 most loss-making orders
select
    `order id`,
    round(sum(profit), 2) as total_profit
from storedata
group by `order id`
order by total_profit asc
limit 10;

-- top 10 states per sales

select state,
sum(sales) as total_sales
from storedata
group by state
order by total_sales desc
limit 10;

-- top 10 customers per sales
select `customer name`,
	round(sum(sales), 2) as total_sales
from storedata
group by `customer name`
order by total_sales desc
limit 10;

-- top 10 customers by profit
select `customer name`,
	round(sum(profit), 2) as total_profit
from storedata
group by `customer name`
order by total_profit desc
limit 10;

-- top 10 states by profit 
select state,
	round(sum(profit), 2) as total_profit
from storedata
group by state
order by total_profit desc
limit 10;

-- top 10 cities by sales
select
    city,
    round(sum(sales), 2) as total_sales
from storedata
group by city
order by total_sales desc
limit 10;

-- top 10 customers by number of orders
select
    `customer name`,
    count(distinct `order id`) as total_orders
from storedata
group by `customer name`
order by total_orders desc
limit 10;

-- most profitable region 
select region,
	sum(profit) as total_profit
from storedata
group by region
order by total_profit desc;

-- most profitable category
select category,
	sum(profit) as total_profit
from storedata
group by category
order by total_profit desc;


-- 6 use cases (monthly trends,top customer,duplicates)

-- monthly sales trend
select 
	date_format(str_to_date(`order date`, '%m/%d/%Y'),
		'%Y-%m'
	) as month,
    round(sum(sales), 2) as total_sales
from storedata
group by month
order by month;

-- monthly order trends

select 
	date_format(str_to_date(`order date`, '%m/%d/%Y'),
		'%Y-%m'
	) as month,
    count(distinct `order id`) as total_orders
from storedata
group by month
order by month;

-- monthly profit trend
select 
	date_format(str_to_date(`order date`, '%m/%d/%Y'),
		'%Y-%m'
	) as month,
    round(sum(profit), 2) as total_profit
from storedata
group by month
order by month;

-- top 10 customers by sales
select `customer name`,
	round(sum(sales), 2) as total_sales
from storedata
group by `customer name`
order by total_sales desc
limit 10;

-- top 10 customers by profit
select `customer name`,
	round(sum(profit), 2) as total_profit
from storedata
group by `customer name`
order by total_profit desc
limit 10;

-- top 10 customers by orders
select `customer name`,
	count(distinct `order id`) as total_orders
from storedata
group by `customer name`
order by total_orders desc
limit 10;

-- duplicate order check
select 
	`order id`,
    count(*) as duplicate_count
from storedata
group by `order id`
having count(*) > 1
order by duplicate_count desc;

-- duplicates in  customer product and order
select
    `order id`,
    `customer id`,
    `product id`,
    count(*) as duplicate_count
from storedata
group by
    `order id`,
    `customer id`,
    `product id`
having count(*) > 1;


-- 7 validate results(row count,data quality)

-- total row count
select count(*) as total_rows
from storedata;

-- null customer ids
select count(*) as null_customer_id
from storedata
where `customer id` is null;

-- null order ids
select count(*) as null_order_id
from storedata
where `order id` is null;

-- null product ids
select count(*) as null_product_id
from storedata
where `product id` is null;

-- null sales values
select count(*) as null_sales
from storedata
where sales is null;

-- null profit values
select count(*) as null_profit
from storedata
where profit is null;

-- null quantity values
select count(*) as null_quantity
from storedata
where quantity is null;

-- negative sales
select * from storedata
where sales < 0;

-- invalid discounts
select * from storedata
where discount < 0 or discount > 1;

-- null regions
select count(*) as null_regions
from storedata
where region is null;

-- null value analysis
select
    count(*) as total_records,
    count(sales) as sales_records,
    count(*) - count(sales) as missing_sales,
    count(profit) as profit_records,
    count(*) - count(profit) as missing_profit,
    count(`customer name`) as customer_records,
    count(*) - count(`customer name`) as missing_customers
from storedata;
