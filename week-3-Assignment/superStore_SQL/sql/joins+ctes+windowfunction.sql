-- JOIN + CTE + Window Functions

-- 1 customer sales ranking 
with customer_sales as (
    select c.customer_id,c.customer_name,
        sum(o.sales) as total_sales
    from customers c
    join orders o
	on c.customer_id = o.customer_id
    group by
        c.customer_id,c.customer_name
)
select customer_id,customer_name,total_sales,
dense_rank() over (
	order by total_sales desc
    ) as customer_rank
from customer_sales;

-- giving a rank to each customer based on how much they spent overall



-- 2 Customer Sales + Profit Ranking

with customer_metrics as (
select
	c.customer_id,c.customer_name,
	sum(o.sales) as total_sales,
	sum(o.profit) as total_profit
    from customers c
    join orders o
	on c.customer_id = o.customer_id
    group by
        c.customer_id,c.customer_name
)
select *,
rank() over (
	order by total_sales desc
) as sales_rank,
rank() over (
        order by total_profit desc
) as profit_rank
from customer_metrics;

-- ranking them by both sales and profit to compare the two



-- 3 top product in every category

with product_sales as (
select
	p.category,p.product_name,
	sum(o.sales) as total_sales
    from products p
    join orders o
	on p.product_id = o.product_id
    group by
        p.category,p.product_name
)
select *,
    dense_rank() over (
	partition by category
	order by total_sales desc
    ) as category_rank
from product_sales;

-- finding the best selling products in each category using ranks
