-- Query 13: First vs most recent category purchased by each customer
-- Uses: ROW_NUMBER() + CTE

WITH ranked_categories AS (
    SELECT
        o.customer_id,
        p.category,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date ASC
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date DESC
        ) AS last_rank
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.customer_id IS NOT NULL
)
SELECT
    f.customer_id,
    f.category AS first_category,
    l.category AS recent_category,
    CASE
        WHEN f.category = l.category THEN 'No'
        ELSE 'Yes'
    END AS category_shift
FROM ranked_categories f
JOIN ranked_categories l
    ON f.customer_id = l.customer_id
   AND f.first_rank = 1
   AND l.last_rank = 1
ORDER BY f.customer_id;
