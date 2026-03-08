USE RetailSalesDB;
GO

/* =========================================================
   06_business_analysis.sql
   Business-focused SQL analysis for decision-making
   ========================================================= */

------------------------------------------------------------
-- 1. Total completed revenue
------------------------------------------------------------
SELECT
    SUM(total_amount) AS total_completed_revenue
FROM Orders
WHERE order_status = 'Completed';
GO

------------------------------------------------------------
-- 2. Total completed orders
------------------------------------------------------------
SELECT
    COUNT(*) AS total_completed_orders
FROM Orders
WHERE order_status = 'Completed';
GO

------------------------------------------------------------
-- 3. Average completed order value
------------------------------------------------------------
SELECT
    AVG(total_amount) AS avg_completed_order_value
FROM Orders
WHERE order_status = 'Completed';
GO

------------------------------------------------------------
-- 4. Revenue by month
------------------------------------------------------------
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS completed_orders,
    SUM(total_amount) AS monthly_revenue
FROM Orders
WHERE order_status = 'Completed'
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;
GO

------------------------------------------------------------
-- 5. Top 5 customers by completed spend
------------------------------------------------------------
SELECT TOP 5
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(o.order_id) AS completed_orders,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
ORDER BY total_spent DESC, completed_orders DESC;
GO

------------------------------------------------------------
-- 6. Customer lifetime value style summary
------------------------------------------------------------
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(CASE WHEN o.order_status = 'Completed' THEN 1 END) AS completed_orders,
    SUM(CASE WHEN o.order_status = 'Completed' THEN o.total_amount ELSE 0 END) AS lifetime_revenue,
    AVG(CASE WHEN o.order_status = 'Completed' THEN o.total_amount END) AS avg_order_value
FROM Customers c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY lifetime_revenue DESC;
GO

------------------------------------------------------------
-- 7. Top 5 products by revenue
------------------------------------------------------------
SELECT TOP 5
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.selling_price) AS total_revenue
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC, total_units_sold DESC;
GO

------------------------------------------------------------
-- 8. Top 5 products by gross profit
------------------------------------------------------------
SELECT TOP 5
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM((oi.selling_price - p.cost_price) * oi.quantity) AS gross_profit
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY gross_profit DESC, total_units_sold DESC;
GO

------------------------------------------------------------
-- 9. Category performance by revenue
------------------------------------------------------------
SELECT
    c.category_name,
    SUM(oi.quantity) AS total_units_sold,
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
ORDER BY category_revenue DESC;
GO

------------------------------------------------------------
-- 10. Category performance by gross profit
------------------------------------------------------------
SELECT
    c.category_name,
    SUM((oi.selling_price - p.cost_price) * oi.quantity) AS category_gross_profit
FROM Categories c
JOIN Products p
    ON c.category_id = p.category_id
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.category_name
ORDER BY category_gross_profit DESC;
GO

------------------------------------------------------------
-- 11. Products with highest margin percentage
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.unit_price,
    p.cost_price,
    ROUND(((p.unit_price - p.cost_price) / p.unit_price) * 100.0, 2) AS margin_percent
FROM Products p
WHERE p.unit_price > 0
ORDER BY margin_percent DESC, p.product_name;
GO

------------------------------------------------------------
-- 12. Cities generating the most revenue
------------------------------------------------------------
SELECT
    c.city,
    c.country,
    SUM(o.total_amount) AS city_revenue
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.city,
    c.country
ORDER BY city_revenue DESC, c.city;
GO

------------------------------------------------------------
-- 13. Payment method contribution
------------------------------------------------------------
SELECT
    p.payment_method,
    COUNT(*) AS payment_count,
    SUM(p.payment_amount) AS total_payment_value
FROM Payments p
GROUP BY p.payment_method
ORDER BY total_payment_value DESC;
GO

------------------------------------------------------------
-- 14. Revenue contribution by customer as % of total
------------------------------------------------------------
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(o.total_amount) AS total_spent
    FROM Customers c
    JOIN Orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
),
total_revenue AS (
    SELECT SUM(total_amount) AS total_completed_revenue
    FROM Orders
    WHERE order_status = 'Completed'
)
SELECT
    cr.customer_id,
    cr.first_name,
    cr.last_name,
    cr.total_spent,
    ROUND((cr.total_spent / tr.total_completed_revenue) * 100.0, 2) AS revenue_contribution_percent
FROM customer_revenue cr
CROSS JOIN total_revenue tr
ORDER BY revenue_contribution_percent DESC;
GO

------------------------------------------------------------
-- 15. Revenue contribution by category as % of total
------------------------------------------------------------
WITH category_revenue AS (
    SELECT
        c.category_name,
        SUM(oi.quantity * oi.selling_price) AS total_revenue
    FROM Categories c
    JOIN Products p
        ON c.category_id = p.category_id
    JOIN Order_Items oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.category_name
),
total_revenue AS (
    SELECT SUM(total_amount) AS total_completed_revenue
    FROM Orders
    WHERE order_status = 'Completed'
)
SELECT
    cr.category_name,
    cr.total_revenue,
    ROUND((cr.total_revenue / tr.total_completed_revenue) * 100.0, 2) AS revenue_contribution_percent
FROM category_revenue cr
CROSS JOIN total_revenue tr
ORDER BY revenue_contribution_percent DESC;
GO

------------------------------------------------------------
-- 16. Identify low-volume but high-margin products
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM((oi.selling_price - p.cost_price) * oi.quantity) AS total_profit,
    ROUND(((p.unit_price - p.cost_price) / p.unit_price) * 100.0, 2) AS margin_percent
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name,
    p.unit_price,
    p.cost_price
ORDER BY margin_percent DESC, total_units_sold ASC;
GO

------------------------------------------------------------
-- 17. Identify high-volume but lower-margin products
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM((oi.selling_price - p.cost_price) * oi.quantity) AS total_profit,
    ROUND(((p.unit_price - p.cost_price) / p.unit_price) * 100.0, 2) AS margin_percent
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name,
    p.unit_price,
    p.cost_price
ORDER BY total_units_sold DESC, margin_percent ASC;
GO

------------------------------------------------------------
-- 18. Revenue and profit side by side by product
------------------------------------------------------------
SELECT
    p.product_name,
    SUM(oi.quantity * oi.selling_price) AS total_revenue,
    SUM((oi.selling_price - p.cost_price) * oi.quantity) AS total_profit
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_name
ORDER BY total_revenue DESC;
GO

------------------------------------------------------------
-- 19. Orders with the highest value
------------------------------------------------------------
SELECT TOP 10
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    o.total_amount
FROM Orders o
JOIN Customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
ORDER BY o.total_amount DESC, o.order_date;
GO

------------------------------------------------------------
-- 20. Executive summary block
------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM Customers) AS total_customers,
    (SELECT COUNT(*) FROM Products) AS total_products,
    (SELECT COUNT(*) FROM Orders WHERE order_status = 'Completed') AS completed_orders,
    (SELECT SUM(total_amount) FROM Orders WHERE order_status = 'Completed') AS completed_revenue,
    (SELECT AVG(total_amount) FROM Orders WHERE order_status = 'Completed') AS avg_completed_order_value;
GO