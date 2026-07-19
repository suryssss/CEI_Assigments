-- Query 4: Customers who ordered but never received a delivery

SELECT DISTINCT
    o.customer_id,
    c.customer_name
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL
  AND o.customer_id NOT IN (
      SELECT customer_id
      FROM orders
      WHERE status = 'DELIVERED'
        AND customer_id IS NOT NULL
  )
ORDER BY o.customer_id;
