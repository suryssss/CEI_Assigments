-- Query 16: Products frequently bought together
-- Uses: self-join on order_items
-- Each pair appears once (product_a < product_b)

SELECT
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(*) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING times_bought_together >= 2
ORDER BY times_bought_together DESC, product_a, product_b;
