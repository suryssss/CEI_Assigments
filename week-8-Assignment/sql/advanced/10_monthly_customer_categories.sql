-- Query 10: Count customers by revenue category each month
-- Uses: nested CTEs
-- High > 10000 | Medium 5000-10000 | Low < 5000

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS order_month,
        o.customer_id,
        ROUND(
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)),
            2
        ) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id IS NOT NULL
    GROUP BY strftime('%Y-%m', o.order_date), o.customer_id
),
labeled AS (
    SELECT
        order_month,
        customer_id,
        CASE
            WHEN monthly_revenue > 10000 THEN 'High'
            WHEN monthly_revenue >= 5000 THEN 'Medium'
            ELSE 'Low'
        END AS revenue_category
    FROM monthly_revenue
)
SELECT
    order_month,
    revenue_category,
    COUNT(*) AS customer_count
FROM labeled
GROUP BY order_month, revenue_category
ORDER BY order_month, revenue_category;
