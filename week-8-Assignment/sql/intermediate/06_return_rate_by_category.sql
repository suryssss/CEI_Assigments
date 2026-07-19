-- Query 6: Return rate per category

SELECT
    p.category,
    ROUND(
        100.0 * SUM(CASE WHEN oi.quantity < 0 THEN ABS(oi.quantity) ELSE 0 END)
        / NULLIF(SUM(ABS(oi.quantity)), 0),
        2
    ) AS return_rate_percent
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY return_rate_percent DESC;
