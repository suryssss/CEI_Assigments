
-- mini project customer insights

--  1 Who are the top 5 customers?   
select * from (
select customer_id,sum(sales) as total_sales
    from orders
    group by customer_id
) t
order by total_sales desc
limit 5;

-- this shows the best 5 customers based on their spending


-- 2  Who are the bottom 5 customers?
select * from (
select customer_id,sum(sales) as total_sales
    from orders
    group by customer_id
) t
order by total_sales
limit 5;

-- gives the 5 customers with the lowest sales



-- 3 Which customers made only one order? 
select customer_id,
count(distinct order_id) as order_count
from orders
group by customer_id
having count(distinct order_id) = 1;

-- these customers just bought from us once

-- 4 Which customers have above-average sales?   
with customer_sales as (
select customer_id,sum(sales) as total_sales
    from orders
    group by customer_id
)
select * from customer_sales
where total_sales > (
select avg(total_sales)
from customer_sales
);

-- finds the people who spend more than the average amount


-- 5 What is the highest order value per customer?
select customer_id,
    max(sales) as highest_order_value
from orders
group by customer_id
order by highest_order_value desc;

-- shows the maximum amount each customer spent on a single order