-- Query 12: Compare each month's revenue with the same month last year
-- Uses: LAG() over year

WITH monthly_revenue AS (
    SELECT
        CAST(strftime('%Y', o.order_date) AS INTEGER) AS year,
        CAST(strftime('%m', o.order_date) AS INTEGER) AS month,
        ROUND(
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)),
            2
        ) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY year, month
)
SELECT
    year,
    month,
    revenue,
    LAG(revenue) OVER (PARTITION BY month ORDER BY year) AS prev_year_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (PARTITION BY month ORDER BY year))
        / NULLIF(LAG(revenue) OVER (PARTITION BY month ORDER BY year), 0),
        2
    ) AS yoy_growth_percent
FROM monthly_revenue
ORDER BY year, month;
