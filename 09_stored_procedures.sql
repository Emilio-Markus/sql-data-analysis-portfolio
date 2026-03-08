USE RetailSalesDB;
GO

/* =========================================================
   09_stored_procedures.sql
   Reusable stored procedures for reporting and analysis
   ========================================================= */

------------------------------------------------------------
-- 1. Top customers by completed spend
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetTopCustomers', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetTopCustomers;
GO

CREATE PROCEDURE dbo.usp_GetTopCustomers
    @TopN INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN)
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
END;
GO

------------------------------------------------------------
-- 2. Sales by date range
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetSalesByDateRange', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetSalesByDateRange;
GO

CREATE PROCEDURE dbo.usp_GetSalesByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

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
        c.country
    FROM Orders o
    JOIN Customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_date BETWEEN @StartDate AND @EndDate
    ORDER BY o.order_date, o.order_id;
END;
GO

------------------------------------------------------------
-- 3. Category performance by category name
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetCategoryPerformance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetCategoryPerformance;
GO

CREATE PROCEDURE dbo.usp_GetCategoryPerformance
    @CategoryName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
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
    WHERE c.category_name = @CategoryName
    GROUP BY c.category_name;
END;
GO

------------------------------------------------------------
-- 4. Customer order history
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetCustomerOrderHistory', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetCustomerOrderHistory;
GO

CREATE PROCEDURE dbo.usp_GetCustomerOrderHistory
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.order_id,
        o.order_date,
        o.order_status,
        o.total_amount
    FROM Orders o
    WHERE o.customer_id = @CustomerID
    ORDER BY o.order_date, o.order_id;
END;
GO

------------------------------------------------------------
-- 5. Product performance by product name
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetProductPerformance', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetProductPerformance;
GO

CREATE PROCEDURE dbo.usp_GetProductPerformance
    @ProductName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
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
    WHERE p.product_name = @ProductName
    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name;
END;
GO

------------------------------------------------------------
-- 6. Monthly sales for a selected year
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetMonthlySalesByYear', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetMonthlySalesByYear;
GO

CREATE PROCEDURE dbo.usp_GetMonthlySalesByYear
    @SalesYear INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        COUNT(CASE WHEN order_status = 'Completed' THEN 1 END) AS completed_orders,
        SUM(CASE WHEN order_status = 'Completed' THEN total_amount ELSE 0 END) AS monthly_revenue
    FROM Orders
    WHERE YEAR(order_date) = @SalesYear
    GROUP BY YEAR(order_date), MONTH(order_date)
    ORDER BY order_month;
END;
GO

------------------------------------------------------------
-- 7. Payment summary by method
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetPaymentMethodSummary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetPaymentMethodSummary;
GO

CREATE PROCEDURE dbo.usp_GetPaymentMethodSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        payment_method,
        COUNT(*) AS payment_count,
        SUM(payment_amount) AS total_paid
    FROM Payments
    GROUP BY payment_method
    ORDER BY total_paid DESC, payment_method;
END;
GO

------------------------------------------------------------
-- 8. Order validation check
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_CheckOrderTotalValidation', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_CheckOrderTotalValidation;
GO

CREATE PROCEDURE dbo.usp_CheckOrderTotalValidation
AS
BEGIN
    SET NOCOUNT ON;

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
        o.total_amount
    ORDER BY o.order_id;
END;
GO

------------------------------------------------------------
-- 9. Orders by status
------------------------------------------------------------
IF OBJECT_ID('dbo.usp_GetOrdersByStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetOrdersByStatus;
GO

CREATE PROCEDURE dbo.usp_GetOrdersByStatus
    @OrderStatus VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        o.order_id,
        o.order_date,
        o.order_status,
        o.total_amount,
        c.first_name,
        c.last_name,
        c.email
    FROM Orders o
    JOIN Customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = @OrderStatus
    ORDER BY o.order_date, o.order_id;
END;
GO

------------------------------------------------------------
-- 10. Test executions
------------------------------------------------------------
EXEC dbo.usp_GetTopCustomers @TopN = 5;
EXEC dbo.usp_GetSalesByDateRange @StartDate = '2025-04-01', @EndDate = '2025-05-31';
EXEC dbo.usp_GetCategoryPerformance @CategoryName = 'Electronics';
EXEC dbo.usp_GetCustomerOrderHistory @CustomerID = 1;
EXEC dbo.usp_GetProductPerformance @ProductName = 'Laptop Pro 15';
EXEC dbo.usp_GetMonthlySalesByYear @SalesYear = 2025;
EXEC dbo.usp_GetPaymentMethodSummary;
EXEC dbo.usp_CheckOrderTotalValidation;
EXEC dbo.usp_GetOrdersByStatus @OrderStatus = 'Completed';
GO