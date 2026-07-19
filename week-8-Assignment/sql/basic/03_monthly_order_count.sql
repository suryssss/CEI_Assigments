-- Query 3: Month-wise order count for the last 12 months

SELECT
    strftime('%Y-%m', order_date) AS order_month,
    COUNT(*) AS order_count
FROM orders
WHERE date(order_date) >= date((SELECT MAX(date(order_date)) FROM orders), '-11 months')
GROUP BY strftime('%Y-%m', order_date)
ORDER BY order_month;
