-- Final Combined Query

with customer_sales as
( select customer_id,sum(sales) as total_sales
    from orders
    group by customer_id
)
select c.customer_name,cs.total_sales,
rank() over(
	order by cs.total_sales desc
) as sales_rank
from customer_sales cs
join customers c
    on cs.customer_id = c.customer_id;
    
-- rank of total sales by each customer 