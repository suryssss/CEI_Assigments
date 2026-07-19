-- Query 2: Top 10 customers by total order value

SELECT
    o.customer_id,
    c.customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS total_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL
GROUP BY o.customer_id, c.customer_name
ORDER BY total_order_value DESC
LIMIT 10;
