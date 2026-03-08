USE RetailSalesDB;
GO

/* =========================================================
   04_data_cleaning.sql
   Data quality checks and validation queries
   ========================================================= */

------------------------------------------------------------
-- 1. Check for nulls in key columns
------------------------------------------------------------
SELECT *
FROM Customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL
   OR city IS NULL
   OR country IS NULL
   OR signup_date IS NULL;
GO

SELECT *
FROM Categories
WHERE category_name IS NULL;
GO

SELECT *
FROM Products
WHERE product_name IS NULL
   OR category_id IS NULL
   OR unit_price IS NULL
   OR cost_price IS NULL
   OR is_active IS NULL;
GO

SELECT *
FROM Orders
WHERE customer_id IS NULL
   OR order_date IS NULL
   OR order_status IS NULL
   OR total_amount IS NULL;
GO

SELECT *
FROM Order_Items
WHERE order_id IS NULL
   OR product_id IS NULL
   OR quantity IS NULL
   OR selling_price IS NULL;
GO

SELECT *
FROM Payments
WHERE order_id IS NULL
   OR payment_method IS NULL
   OR payment_date IS NULL
   OR payment_amount IS NULL;
GO

------------------------------------------------------------
-- 2. Check for duplicate customers by email
------------------------------------------------------------
SELECT
    email,
    COUNT(*) AS duplicate_count
FROM Customers
GROUP BY email
HAVING COUNT(*) > 1;
GO

------------------------------------------------------------
-- 3. Check for duplicate categories by name
------------------------------------------------------------
SELECT
    category_name,
    COUNT(*) AS duplicate_count
FROM Categories
GROUP BY category_name
HAVING COUNT(*) > 1;
GO

------------------------------------------------------------
-- 4. Check for duplicate products by product name
------------------------------------------------------------
SELECT
    product_name,
    COUNT(*) AS duplicate_count
FROM Products
GROUP BY product_name
HAVING COUNT(*) > 1;
GO

------------------------------------------------------------
-- 5. Check for invalid product pricing
-- unit_price should be > 0
-- cost_price should be >= 0 and not exceed unit_price
------------------------------------------------------------
SELECT *
FROM Products
WHERE unit_price <= 0
   OR cost_price < 0
   OR cost_price > unit_price;
GO

------------------------------------------------------------
-- 6. Check for invalid order item values
------------------------------------------------------------
SELECT *
FROM Order_Items
WHERE quantity <= 0
   OR selling_price < 0;
GO

------------------------------------------------------------
-- 7. Check for invalid payment values
------------------------------------------------------------
SELECT *
FROM Payments
WHERE payment_amount < 0;
GO

------------------------------------------------------------
-- 8. Check for orphan records
-- These should return zero rows if foreign keys are working
------------------------------------------------------------
SELECT oi.*
FROM Order_Items oi
LEFT JOIN Orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
GO

SELECT oi.*
FROM Order_Items oi
LEFT JOIN Products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
GO

SELECT o.*
FROM Orders o
LEFT JOIN Customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
GO

SELECT p.*
FROM Products p
LEFT JOIN Categories c
    ON p.category_id = c.category_id
WHERE c.category_id IS NULL;
GO

SELECT py.*
FROM Payments py
LEFT JOIN Orders o
    ON py.order_id = o.order_id
WHERE o.order_id IS NULL;
GO

------------------------------------------------------------
-- 9. Check recorded order totals vs calculated totals
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
HAVING o.total_amount <> SUM(oi.quantity * oi.selling_price);
GO

------------------------------------------------------------
-- 10. Check completed orders with no payment
------------------------------------------------------------
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount
FROM Orders o
LEFT JOIN Payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'Completed'
  AND p.order_id IS NULL;
GO

------------------------------------------------------------
-- 11. Check payments that do not match order totals
------------------------------------------------------------
SELECT
    o.order_id,
    o.order_status,
    o.total_amount,
    p.payment_amount,
    o.total_amount - p.payment_amount AS difference
FROM Orders o
JOIN Payments p
    ON o.order_id = p.order_id
WHERE o.total_amount <> p.payment_amount;
GO

------------------------------------------------------------
-- 12. Check cancelled orders that still have payments
------------------------------------------------------------
SELECT
    o.order_id,
    o.order_status,
    p.payment_id,
    p.payment_amount
FROM Orders o
JOIN Payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'Cancelled';
GO

------------------------------------------------------------
-- 13. Check pending orders that already have payments
-- not always wrong, but worth reviewing

--A data audit identified one order marked as Pending that already has a recorded payment.
--This may indicate a delay in order status updates or a workflow inconsistency between payment processing and order management systems.
------------------------------------------------------------
SELECT
    o.order_id,
    o.order_status,
    p.payment_id,
    p.payment_amount
FROM Orders o
JOIN Payments p
    ON o.order_id = p.order_id
WHERE o.order_status = 'Pending';
GO

------------------------------------------------------------
-- 14. Check order dates before signup dates
------------------------------------------------------------
SELECT
    o.order_id,
    c.customer_id,
    c.signup_date,
    o.order_date
FROM Orders o
JOIN Customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date < c.signup_date;
GO

------------------------------------------------------------
-- 15. Check inactive products that still appear in orders
-- useful for future maintenance
------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.is_active,
    oi.order_id
FROM Products p
JOIN Order_Items oi
    ON p.product_id = oi.product_id
WHERE p.is_active = 0;
GO

------------------------------------------------------------
-- 16. Summary audit report
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

