USE RetailSalesDB;
GO

/* =========================================================
   05_exploratory_queries.sql
   Exploratory analysis to understand the dataset
   ========================================================= */

------------------------------------------------------------
-- 1. Row counts for each table
------------------------------------------------------------
SELECT 'Customers' AS table_name, COUNT(*) AS row_count FROM Customers
UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL
SELECT 'Order_Items', COUNT(*) FROM Order_Items
UNION ALL
SELECT 'Payments', COUNT(*) FROM Payments;
GO

------------------------------------------------------------
-- 2. View all customers
------------------------------------------------------------
SELECT *
FROM Customers
ORDER BY customer_id;
GO

------------------------------------------------------------
-- 3. View all categories
------------------------------------------------------------
SELECT *
FROM Categories
ORDER BY category_id;
GO

------------------------------------------------------------
-- 4. View products with category names
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.unit_price,
    p.cost_price,
    p.is_active
FROM Products p
JOIN Categories c
    ON p.category_id = c.category_id
ORDER BY c.category_name, p.product_name;
GO

------------------------------------------------------------
-- 5. View all orders with customer names
------------------------------------------------------------
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.country
FROM Orders o
JOIN Customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date, o.order_id;
GO

------------------------------------------------------------
-- 6. View order items with product names
------------------------------------------------------------
SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.selling_price,
    (oi.quantity * oi.selling_price) AS line_total
FROM Order_Items oi
JOIN Products p
    ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;
GO

------------------------------------------------------------
-- 7. View payments with order info
------------------------------------------------------------
SELECT
    p.payment_id,
    p.order_id,
    p.payment_method,
    p.payment_date,
    p.payment_amount,
    o.order_status
FROM Payments p
JOIN Orders o
    ON p.order_id = o.order_id
ORDER BY p.payment_date, p.payment_id;
GO

------------------------------------------------------------
-- 8. Customer geographic distribution
------------------------------------------------------------
SELECT
    country,
    city,
    COUNT(*) AS customer_count
FROM Customers
GROUP BY country, city
ORDER BY customer_count DESC, country, city;
GO

------------------------------------------------------------
-- 9. Product distribution by category
------------------------------------------------------------
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM Categories c
LEFT JOIN Products p
    ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY product_count DESC, c.category_name;
GO

------------------------------------------------------------
-- 10. Orders by status
------------------------------------------------------------
SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_amount
FROM Orders
GROUP BY order_status
ORDER BY order_count DESC;
GO

------------------------------------------------------------
-- 11. Payment methods overview
------------------------------------------------------------
SELECT
    payment_method,
    COUNT(*) AS payment_count,
    SUM(payment_amount) AS total_paid
FROM Payments
GROUP BY payment_method
ORDER BY total_paid DESC;
GO

------------------------------------------------------------
-- 12. Distinct order dates and range
------------------------------------------------------------
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS date_span_days
FROM Orders;
GO

------------------------------------------------------------
-- 13. Distinct signup dates and range
------------------------------------------------------------
SELECT
    MIN(signup_date) AS first_signup_date,
    MAX(signup_date) AS last_signup_date,
    DATEDIFF(DAY, MIN(signup_date), MAX(signup_date)) AS signup_span_days
FROM Customers;
GO

------------------------------------------------------------
-- 14. Revenue by order date
------------------------------------------------------------
SELECT
    order_date,
    COUNT(*) AS orders_count,
    SUM(total_amount) AS daily_revenue
FROM Orders
WHERE order_status = 'Completed'
GROUP BY order_date
ORDER BY order_date;
GO

------------------------------------------------------------
-- 15. Total units sold by product
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC, p.product_name;
GO

------------------------------------------------------------
-- 16. Revenue by product
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC, p.product_name;
GO

------------------------------------------------------------
-- 17. Revenue by category
------------------------------------------------------------
SELECT
    c.category_name,
    SUM(oi.quantity * oi.selling_price) AS category_revenue
FROM Categories c
JOIN Products p
    ON c.category_id = p.category_id
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_name
ORDER BY category_revenue DESC, c.category_name;
GO

------------------------------------------------------------
-- 18. Gross profit by product
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    SUM((oi.selling_price - p.cost_price) * oi.quantity) AS gross_profit
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY gross_profit DESC, p.product_name;
GO

------------------------------------------------------------
-- 19. Average order value for completed orders
------------------------------------------------------------
SELECT
    AVG(total_amount) AS avg_completed_order_value
FROM Orders
WHERE order_status = 'Completed';
GO

------------------------------------------------------------
-- 20. Customer order frequency
------------------------------------------------------------
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC, c.last_name, c.first_name;
GO

------------------------------------------------------------
-- 21. Customer spend summary
------------------------------------------------------------
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(CASE WHEN o.order_status = 'Completed' THEN o.total_amount ELSE 0 END) AS completed_spend,
    COUNT(CASE WHEN o.order_status = 'Completed' THEN 1 END) AS completed_orders
FROM Customers c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY completed_spend DESC, completed_orders DESC;
GO

------------------------------------------------------------
-- 22. Check difference between recorded order totals and line totals
------------------------------------------------------------
SELECT
    o.order_id,
    o.total_amount AS recorded_total,
    SUM(oi.quantity * oi.selling_price) AS calculated_total,
    o.total_amount - SUM(oi.quantity * oi.selling_price) AS difference
FROM Orders o
JOIN Order_Items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
ORDER BY o.order_id;
GO