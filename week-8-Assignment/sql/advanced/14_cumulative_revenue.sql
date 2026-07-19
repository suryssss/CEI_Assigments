-- Query 14: Cumulative revenue share by customer
-- Uses: running SUM() window function

WITH customer_revenue AS (
    SELECT
        o.customer_id,
        ROUND(
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)),
            2
        ) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY revenue DESC, customer_id
        ),
        2
    ) AS cumulative_revenue,
    ROUND(
        100.0 * SUM(revenue) OVER (
            ORDER BY revenue DESC, customer_id
        ) / SUM(revenue) OVER (),
        2
    ) AS cumulative_percent
FROM customer_revenue
ORDER BY revenue DESC;
