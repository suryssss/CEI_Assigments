-- Query 9: Days between consecutive orders
-- Uses: LAG() window function
-- Flags customers with average gap > 30 days as "At Risk"

WITH customer_order_dates AS (
    SELECT
        customer_id,
        date(order_date) AS order_date
    FROM orders
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, date(order_date)
),
order_gaps AS (
    SELECT
        customer_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_order_date,
        julianday(order_date) - julianday(
            LAG(order_date) OVER (
                PARTITION BY customer_id
                ORDER BY order_date
            )
        ) AS days_gap
    FROM customer_order_dates
)
SELECT
    og.customer_id,
    og.order_date,
    og.previous_order_date,
    ROUND(og.days_gap, 0) AS days_gap,
    CASE
        WHEN AVG(og.days_gap) OVER (PARTITION BY og.customer_id) > 30 THEN 'At Risk'
        ELSE 'Active'
    END AS customer_status
FROM order_gaps og
WHERE og.previous_order_date IS NOT NULL
ORDER BY og.customer_id, og.order_date;
