-- Query 11: Segment customers into quartiles by lifetime value
-- Uses: NTILE(4)
-- Labels: Platinum, Gold, Silver, Bronze

WITH customer_value AS (
    SELECT
        o.customer_id,
        ROUND(
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)),
            2
        ) AS total_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    total_value,
    NTILE(4) OVER (ORDER BY total_value DESC) AS quartile,
    CASE NTILE(4) OVER (ORDER BY total_value DESC)
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        ELSE 'Bronze'
    END AS quartile_label
FROM customer_value
ORDER BY total_value DESC;
