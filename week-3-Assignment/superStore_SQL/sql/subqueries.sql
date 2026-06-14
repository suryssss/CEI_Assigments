-- Subquery analysis

-- 1 orders with sales greater than overall average
select * from orders
where sales>
(	select avg(sales)
	from orders
)
limit 20;

-- pulling a few orders that are higher than the average sale price


-- 2 highest value order for every customer
select * from orders o
where sales = 
( select max(sales) from orders
	where customer_id=o.customer_id
)
limit 20;

-- finding the most expensive order for each customer



-- 3 customers above average sales
select customer_id, sum(sales) as total_sales
from orders
group by customer_id
having sum(sales)>
( 	select avg(customer_sales)
	from (
		select sum(sales) as customer_sales
        from orders
        group by customer_id 
	) t
)
order by total_sales desc
limit 20;

-- only keeping customers who spent more than the average customer


-- 4 products sold above average quantity
select * from products 
where product_id in 
(	
	select product_id from orders
	group by product_id
    having sum(quantity)>
		(	
        select avg(total_quantity)
		from (
				select sum(quantity) as total_quantity from orders
                group by product_id
                )t
		)
)
limit 20;

-- finding products that are selling better than average



-- 5 products never ordered
select * from products p 
where not exists 
(	select 1
	from orders o
    where o.product_id =p.product_id
);

-- checking for products that have zero sales
