-- Query 15: Cohort retention by registration month
-- Tracks orders in month 0, 1, 2, and 3 after registration

WITH cohorts AS (
    SELECT
        customer_id,
        registration_date,
        strftime('%Y-%m', registration_date) AS cohort_month
    FROM customers
),
activity AS (
    SELECT
        c.cohort_month,
        o.customer_id,
        (
            (CAST(strftime('%Y', o.order_date) AS INTEGER) - CAST(strftime('%Y', c.registration_date) AS INTEGER)) * 12
            + (CAST(strftime('%m', o.order_date) AS INTEGER) - CAST(strftime('%m', c.registration_date) AS INTEGER))
        ) AS month_offset
    FROM orders o
    JOIN cohorts c ON o.customer_id = c.customer_id
    WHERE o.customer_id IS NOT NULL
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    a.month_offset,
    cs.cohort_size,
    COUNT(DISTINCT a.customer_id) AS active_customers,
    ROUND(
        100.0 * COUNT(DISTINCT a.customer_id) / cs.cohort_size,
        2
    ) AS retention_rate_percent
FROM activity a
JOIN cohort_size cs ON a.cohort_month = cs.cohort_month
WHERE a.month_offset BETWEEN 0 AND 3
GROUP BY a.cohort_month, a.month_offset, cs.cohort_size
ORDER BY a.cohort_month, a.month_offset;
