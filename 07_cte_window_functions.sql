USE RetailSalesDB;
GO

/* =========================================================
   07_cte_window_functions.sql
   Advanced SQL using CTEs and window functions
   ========================================================= */

------------------------------------------------------------
-- 1. Rank customers by completed spend
------------------------------------------------------------
WITH customer_spend AS (
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
)
SELECT
    customer_id,
    first_name,
    last_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM customer_spend
ORDER BY spend_rank, customer_id;
GO

------------------------------------------------------------
-- 2. Dense rank products by revenue
------------------------------------------------------------
WITH product_revenue AS (
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
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    total_revenue,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM product_revenue
ORDER BY revenue_rank, product_name;
GO

------------------------------------------------------------
-- 3. Rank products within each category by revenue
------------------------------------------------------------
WITH category_product_revenue AS (
    SELECT
        c.category_name,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.selling_price) AS total_revenue
    FROM Categories c
    JOIN Products p
        ON c.category_id = p.category_id
    JOIN Order_Items oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        c.category_name,
        p.product_id,
        p.product_name
)
SELECT
    category_name,
    product_id,
    product_name,
    total_revenue,
    RANK() OVER (
        PARTITION BY category_name
        ORDER BY total_revenue DESC
    ) AS category_revenue_rank
FROM category_product_revenue
ORDER BY category_name, category_revenue_rank, product_name;
GO

------------------------------------------------------------
-- 4. Running total revenue by order date
------------------------------------------------------------
WITH daily_revenue AS (
    SELECT
        order_date,
        SUM(total_amount) AS revenue
    FROM Orders
    WHERE order_status = 'Completed'
    GROUP BY order_date
)
SELECT
    order_date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM daily_revenue
ORDER BY order_date;
GO

------------------------------------------------------------
-- 5. Monthly revenue with previous month comparison
------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS revenue_month,
        SUM(total_amount) AS monthly_revenue
    FROM Orders
    WHERE order_status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    revenue_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY revenue_month) AS previous_month_revenue,
    monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY revenue_month) AS revenue_change
FROM monthly_revenue
ORDER BY revenue_month;
GO

------------------------------------------------------------
-- 6. Customer order sequence number
------------------------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        o.order_id,
        o.order_date,
        o.total_amount
    FROM Customers c
    JOIN Orders o
        ON c.customer_id = o.customer_id
)
SELECT
    customer_id,
    first_name,
    last_name,
    order_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS order_sequence
FROM customer_orders
ORDER BY customer_id, order_sequence;
GO

------------------------------------------------------------
-- 7. First and last order date per customer
------------------------------------------------------------
WITH customer_order_dates AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        o.order_date
    FROM Customers c
    JOIN Orders o
        ON c.customer_id = o.customer_id
)
SELECT
    customer_id,
    first_name,
    last_name,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM customer_order_dates
GROUP BY
    customer_id,
    first_name,
    last_name
ORDER BY customer_id;
GO

------------------------------------------------------------
-- 8. Revenue contribution cumulative percentage by customer
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
ranked_customers AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        total_spent,
        SUM(total_spent) OVER (ORDER BY total_spent DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
        SUM(total_spent) OVER () AS overall_revenue
    FROM customer_revenue
)
SELECT
    customer_id,
    first_name,
    last_name,
    total_spent,
    cumulative_revenue,
    ROUND((cumulative_revenue / overall_revenue) * 100.0, 2) AS cumulative_revenue_percent
FROM ranked_customers
ORDER BY total_spent DESC;
GO

------------------------------------------------------------
-- 9. Top-selling product per category
------------------------------------------------------------
WITH product_sales AS (
    SELECT
        c.category_name,
        p.product_name,
        SUM(oi.quantity) AS total_units_sold
    FROM Categories c
    JOIN Products p
        ON c.category_id = p.category_id
    JOIN Order_Items oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        c.category_name,
        p.product_name
),
ranked_products AS (
    SELECT
        category_name,
        product_name,
        total_units_sold,
        RANK() OVER (
            PARTITION BY category_name
            ORDER BY total_units_sold DESC
        ) AS sales_rank
    FROM product_sales
)
SELECT
    category_name,
    product_name,
    total_units_sold
FROM ranked_products
WHERE sales_rank = 1
ORDER BY category_name;
GO

------------------------------------------------------------
-- 10. Highest value order per customer
------------------------------------------------------------
WITH customer_order_values AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        o.order_id,
        o.order_date,
        o.total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.total_amount DESC, o.order_date
        ) AS value_rank
    FROM Customers c
    JOIN Orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
)
SELECT
    customer_id,
    first_name,
    last_name,
    order_id,
    order_date,
    total_amount
FROM customer_order_values
WHERE value_rank = 1
ORDER BY total_amount DESC;
GO

------------------------------------------------------------
-- 11. Product profit ranking
------------------------------------------------------------
WITH product_profit AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM((oi.selling_price - p.cost_price) * oi.quantity) AS total_profit
    FROM Products p
    JOIN Order_Items oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    total_profit,
    RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM product_profit
ORDER BY profit_rank, product_name;
GO

------------------------------------------------------------
-- 12. Gap between each customer's orders
------------------------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        o.order_id,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date, o.order_id
        ) AS previous_order_date
    FROM Customers c
    JOIN Orders o
        ON c.customer_id = o.customer_id
)
SELECT
    customer_id,
    first_name,
    last_name,
    order_id,
    order_date,
    previous_order_date,
    DATEDIFF(DAY, previous_order_date, order_date) AS days_since_previous_order
FROM customer_orders
ORDER BY customer_id, order_date;
GO

------------------------------------------------------------
-- 13. Revenue quartiles by customer
------------------------------------------------------------
WITH customer_spend AS (
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
)
SELECT
    customer_id,
    first_name,
    last_name,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spend_quartile
FROM customer_spend
ORDER BY total_spent DESC;
GO

------------------------------------------------------------
-- 14. Monthly revenue share of total revenue
------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS revenue_month,
        SUM(total_amount) AS monthly_revenue
    FROM Orders
    WHERE order_status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    revenue_month,
    monthly_revenue,
    ROUND(
        (monthly_revenue / SUM(monthly_revenue) OVER ()) * 100.0,
        2
    ) AS revenue_share_percent
FROM monthly_revenue
ORDER BY revenue_month;
GO

------------------------------------------------------------
-- 15. Most recent order for each customer
------------------------------------------------------------
WITH ranked_orders AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        o.order_id,
        o.order_date,
        o.total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date DESC, o.order_id DESC
        ) AS recent_rank
    FROM Customers c
    JOIN Orders o
        ON c.customer_id = o.customer_id
)
SELECT
    customer_id,
    first_name,
    last_name,
    order_id,
    order_date,
    total_amount
FROM ranked_orders
WHERE recent_rank = 1
ORDER BY order_date DESC, customer_id;
GO