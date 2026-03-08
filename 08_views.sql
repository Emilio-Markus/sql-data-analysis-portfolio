USE RetailSalesDB;
GO

/* =========================================================
   08_views.sql
   Reusable reporting views
   ========================================================= */

------------------------------------------------------------
-- 1. Customer order summary view
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_customer_order_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_customer_order_summary;
GO

CREATE VIEW dbo.vw_customer_order_summary AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.city,
    c.country,
    COUNT(o.order_id) AS total_orders,
    COUNT(CASE WHEN o.order_status = 'Completed' THEN 1 END) AS completed_orders,
    SUM(CASE WHEN o.order_status = 'Completed' THEN o.total_amount ELSE 0 END) AS completed_revenue,
    AVG(CASE WHEN o.order_status = 'Completed' THEN o.total_amount END) AS avg_completed_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM Customers c
LEFT JOIN Orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.city,
    c.country;
GO

------------------------------------------------------------
-- 2. Product sales summary view
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_product_sales_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_product_sales_summary;
GO

CREATE VIEW dbo.vw_product_sales_summary AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.unit_price,
    p.cost_price,
    p.is_active,
    SUM(CASE WHEN o.order_status = 'Completed' THEN oi.quantity ELSE 0 END) AS total_units_sold,
    SUM(CASE WHEN o.order_status = 'Completed' THEN oi.quantity * oi.selling_price ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN o.order_status = 'Completed' THEN (oi.selling_price - p.cost_price) * oi.quantity ELSE 0 END) AS total_profit
FROM Products p
JOIN Categories c
    ON p.category_id = c.category_id
LEFT JOIN Order_Items oi
    ON p.product_id = oi.product_id
LEFT JOIN Orders o
    ON oi.order_id = o.order_id
GROUP BY
    p.product_id,
    p.product_name,
    c.category_name,
    p.unit_price,
    p.cost_price,
    p.is_active;
GO

------------------------------------------------------------
-- 3. Category performance view
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_category_performance', 'V') IS NOT NULL
    DROP VIEW dbo.vw_category_performance;
GO

CREATE VIEW dbo.vw_category_performance AS
SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT p.product_id) AS total_products,
    SUM(CASE WHEN o.order_status = 'Completed' THEN oi.quantity ELSE 0 END) AS total_units_sold,
    SUM(CASE WHEN o.order_status = 'Completed' THEN oi.quantity * oi.selling_price ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN o.order_status = 'Completed' THEN (oi.selling_price - p.cost_price) * oi.quantity ELSE 0 END) AS total_profit
FROM Categories c
LEFT JOIN Products p
    ON c.category_id = p.category_id
LEFT JOIN Order_Items oi
    ON p.product_id = oi.product_id
LEFT JOIN Orders o
    ON oi.order_id = o.order_id
GROUP BY
    c.category_id,
    c.category_name;
GO

------------------------------------------------------------
-- 4. Monthly sales view
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_monthly_sales', 'V') IS NOT NULL
    DROP VIEW dbo.vw_monthly_sales;
GO

CREATE VIEW dbo.vw_monthly_sales AS
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS revenue_month,
    COUNT(CASE WHEN order_status = 'Completed' THEN 1 END) AS completed_orders,
    SUM(CASE WHEN order_status = 'Completed' THEN total_amount ELSE 0 END) AS monthly_revenue
FROM Orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1);
GO

------------------------------------------------------------
-- 5. Order detail reporting view
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_order_detail', 'V') IS NOT NULL
    DROP VIEW dbo.vw_order_detail;
GO

CREATE VIEW dbo.vw_order_detail AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.city,
    c.country,
    oi.order_item_id,
    p.product_id,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.selling_price,
    (oi.quantity * oi.selling_price) AS line_total,
    p.cost_price,
    ((oi.selling_price - p.cost_price) * oi.quantity) AS line_profit
FROM Orders o
JOIN Customers c
    ON o.customer_id = c.customer_id
LEFT JOIN Order_Items oi
    ON o.order_id = oi.order_id
LEFT JOIN Products p
    ON oi.product_id = p.product_id
LEFT JOIN Categories cat
    ON p.category_id = cat.category_id;
GO

------------------------------------------------------------
-- 6. Payment summary view
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_payment_summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_payment_summary;
GO

CREATE VIEW dbo.vw_payment_summary AS
SELECT
    p.payment_id,
    p.order_id,
    p.payment_method,
    p.payment_date,
    p.payment_amount,
    o.order_status,
    o.order_date,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM Payments p
JOIN Orders o
    ON p.order_id = o.order_id
JOIN Customers c
    ON o.customer_id = c.customer_id;
GO

------------------------------------------------------------
-- 7. Order total validation view
------------------------------------------------------------
IF OBJECT_ID('dbo.vw_order_total_validation', 'V') IS NOT NULL
    DROP VIEW dbo.vw_order_total_validation;
GO

CREATE VIEW dbo.vw_order_total_validation AS
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount AS recorded_total,
    SUM(oi.quantity * oi.selling_price) AS calculated_total,
    o.total_amount - SUM(oi.quantity * oi.selling_price) AS difference
FROM Orders o
JOIN Order_Items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount;
GO

------------------------------------------------------------
-- 8. Quick test queries for the views
------------------------------------------------------------
SELECT * FROM dbo.vw_customer_order_summary;
SELECT * FROM dbo.vw_product_sales_summary;
SELECT * FROM dbo.vw_category_performance;
SELECT * FROM dbo.vw_monthly_sales;
SELECT * FROM dbo.vw_order_detail;
SELECT * FROM dbo.vw_payment_summary;
SELECT * FROM dbo.vw_order_total_validation;
GO