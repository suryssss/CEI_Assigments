
-- 1 Rank States by Total Profit
with state_profit as (
    select state,
    sum(profit) as total_profit
    from orders
    group by state
)

select *,
dense_rank() over(
    order by total_profit desc
) as profit_rank
from state_profit;
--Shows highest profit generating states and if there are ties in profit they get same rank


-- 2 Customer's First and Latest Order
select
    c.customer_name,
    min(o.order_date) as first_order,
    max(o.order_date) as latest_order
from customers c
join orders o
    on c.customer_id = o.customer_id
group by c.customer_name;
-- gets the first and the latest order of a specific person 


-- 3 products that generate loss
with product_profit as (
    select
        p.product_name,
        sum(o.profit) as total_profit
    from orders o
    join products p
        on o.product_id = p.product_id
    group by p.product_name
)

select *
from product_profit
where total_profit < 0
order by total_profit;
-- helps to get the products that are generating loss



-- 4 daily sales trends
with daily_sales as (
    select
        order_date,
        sum(sales) as total_sales
    from orders
    group by order_date
)

select *
from daily_sales
order by order_date;
-- gets the daily sales and is useful to find the trend 


-- 5 profit by category
select
    p.category,
    sum(o.profit) as total_profit
from products p
join orders o
    on p.product_id = o.product_id
group by p.category;
-- gets the profit by category and is useful to find the best category

-- 6 no of orders per customer
select c.customer_name,
    count(*) as total_orders
from customers c
join orders o
    on c.customer_id = o.customer_id
group by c.customer_name
order by total_orders desc;

-- just counting how many orders each customer has made