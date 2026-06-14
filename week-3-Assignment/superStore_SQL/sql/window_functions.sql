-- Window functions

-- 1 row_number() - rank all customers by total sales globally
select customer_id, sum(sales) as total_sales,
	row_number() over (order by sum(sales) desc
        ) as sales_rank
from orders
group by customer_id;

-- numbering all customers by their total sales



-- 2 rank() with partition by - rank customers within each region
select customer_id, region, sum(sales) as total_sales,
	rank() over (
		partition by region order by sum(sales) desc
        ) as region_rank
from orders
group by customer_id, region;

-- ranking our customers but keeping it separate for each region


-- 3 dense_rank() with partition by - rank products within each category
select product_id, category, sum(sales) as total_sales,
	dense_rank() over (
		partition by category
		order by sum(sales) desc
        ) as category_rank
from orders
join products using(product_id)
group by product_id, category;

-- giving ranks to products inside their specific categories


-- 4 running total sales
select customer_id,order_id,sales,
       SUM(sales) 
       over(partition by
       customer_id 
       order by order_date) run_total
from orders;

-- keeping a running total of sales over time for each person

-- 5 Calculate difference from previous order
select customer_id,order_id,sales,
    sales -
    lag(sales) over(
	partition by customer_id
	order by order_date
    ) as sales_diff
from orders;

-- finding the difference in sales between a customer's current and previous order
