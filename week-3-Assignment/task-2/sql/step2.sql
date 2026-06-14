-- 1 Orders where sales are greater than average sales
select * from orders
where sales >
(   select avg(sales)
    from orders
);

-- getting all orders that have a higher sale amount than the average


-- 2 Highest sales order for each customer
select * from orders o
where sales =
(	select max(sales) from orders
    where customer_id = o.customer_id
);

-- find the biggest single order for every customer

-- 3 Total sales for each customer (CTE)
with customer_sales as
(select customer_id,sum(sales) as total_sales
    from orders
    group by customer_id
)
select * from customer_sales;

-- calculates total money spent by each customer


-- 4  Customers whose total sales are above average
with customer_sales as
( select customer_id, sum(sales) as total_sales
    from orders
    group by customer_id
)
select * from customer_sales
	where total_sales >
(select avg(total_sales)
from customer_sales
);

-- filters out customers who spent less than the average

--  5 Rank customers based on total sales
with customer_sales as
(select customer_id, sum(sales) as total_sales
    from orders
    group by customer_id
)
select customer_id,total_sales,
rank() over(
	order by total_sales desc
) as sales_rank
from customer_sales;

-- gives a rank number to each customer by how much they bought


-- 6 Row numbers for each order within a customer
select customer_id,order_id,sales,
row_number() over(
	partition by customer_id
	order by sales desc
) as row_num
from orders;

-- numbers the orders for each customer starting from their highest sale


-- 7 Top 3 customers based on total sales
with customer_sales as
(select customer_id,sum(sales) as total_sales
from orders
    group by customer_id
),
ranked_customers as
( select *,
	rank() over(
		order by total_sales desc
	) as sales_rank
    from customer_sales
)
select * from ranked_customers
where sales_rank <= 3;

-- finally get the top 3 customers using the rank we made
