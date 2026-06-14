-- Common table expression

-- 1 total Sales Per Customer
with customer_sales as
(
    select customer_id,sum(sales) AS total_sales
    from orders
    group by customer_id
)

select * from customer_sales
order by total_sales desc;

-- calculating the total amount bought by each person


-- 2 regional sales
with region_sales as 
(
	select region,sum(sales) as total_sales
    from orders
    group by region
)
select * from region_sales
order by total_sales desc;

-- finding out which region brings in the most sales


-- 3 total profit per customer
with customer_profit as 
(
	select customer_id,sum(profit) as total_profit
    from orders
    group by customer_id
)
select * from customer_profit
order by total_profit desc;

-- checking who is the most profitable customer for us



-- 4 monthly sales trend
with monthly_sales as (
	select 
    year(order_date) as year,month(order_date) as month,
    sum(sales) as total_sales
    from orders
    group by 
    year(order_date),month(order_date)
)
select * from monthly_sales
order by year,month;

-- looking at sales month by month to see how we did



-- 5 customer with above average revenue
with customer_sales as 
(
	select customer_id,sum(sales) as total_sales
    from orders
    group by customer_id
)
select * from customer_sales
where total_sales>
(
	select avg(total_sales)
    from customer_sales
)
order by total_sales desc;

-- getting only the top buyers who spent more than the average


-- 6 total orders per customer
with customer_orders as
(
	select customer_id, count(distinct order_id) as order_count
    from orders
    group by customer_id
)
select * from customer_orders
order by order_count desc;

-- seeing how many separate times each customer bought something



-- 7 average order value per customer
with avg_order as
(
	select customer_id, avg(sales) as avg_order_value
    from orders
    group by customer_id
)
select * from avg_order
order by avg_order_value desc;

-- finding out the average spend per order for every customer
