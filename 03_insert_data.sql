USE RetailSalesDB;
GO

/* =========================================================
   03_insert_data.sql
   ========================================================= */

------------------------------------------------------------
-- 1. Insert Categories
------------------------------------------------------------
INSERT INTO Categories (category_name)
VALUES
('Electronics'),
('Home Appliances'),
('Furniture'),
('Office Supplies'),
('Fitness Equipment');
GO

------------------------------------------------------------
-- 2. Insert Customers
------------------------------------------------------------
INSERT INTO Customers (first_name, last_name, email, city, country, signup_date)
VALUES
('John',    'Smith',    'john.smith@email.com',    'New York',      'USA', '2025-01-10'),
('Emma',    'Johnson',  'emma.johnson@email.com',  'Los Angeles',   'USA', '2025-01-15'),
('Michael', 'Brown',    'michael.brown@email.com', 'Chicago',       'USA', '2025-02-01'),
('Sophia',  'Davis',    'sophia.davis@email.com',  'Houston',       'USA', '2025-02-08'),
('Daniel',  'Wilson',   'daniel.wilson@email.com', 'Phoenix',       'USA', '2025-02-15'),
('Olivia',  'Miller',   'olivia.miller@email.com', 'Philadelphia',  'USA', '2025-03-01'),
('James',   'Moore',    'james.moore@email.com',   'San Antonio',   'USA', '2025-03-05'),
('Ava',     'Taylor',   'ava.taylor@email.com',    'San Diego',     'USA', '2025-03-10'),
('William', 'Anderson', 'william.anderson@email.com','Dallas',      'USA', '2025-03-20'),
('Mia',     'Thomas',   'mia.thomas@email.com',    'San Jose',      'USA', '2025-03-25');
GO

------------------------------------------------------------
-- 3. Insert Products
------------------------------------------------------------
INSERT INTO Products (product_name, category_id, unit_price, cost_price, is_active)
SELECT 'Laptop Pro 15', c.category_id, 1200.00, 900.00, 1
FROM Categories c
WHERE c.category_name = 'Electronics'
UNION ALL
SELECT 'Wireless Headphones', c.category_id, 180.00, 95.00, 1
FROM Categories c
WHERE c.category_name = 'Electronics'
UNION ALL
SELECT 'Smartphone X', c.category_id, 950.00, 700.00, 1
FROM Categories c
WHERE c.category_name = 'Electronics'
UNION ALL
SELECT 'Microwave Oven', c.category_id, 220.00, 140.00, 1
FROM Categories c
WHERE c.category_name = 'Home Appliances'
UNION ALL
SELECT 'Air Fryer Max', c.category_id, 160.00, 100.00, 1
FROM Categories c
WHERE c.category_name = 'Home Appliances'
UNION ALL
SELECT 'Luxury Sofa', c.category_id, 850.00, 620.00, 1
FROM Categories c
WHERE c.category_name = 'Furniture'
UNION ALL
SELECT 'Office Desk', c.category_id, 320.00, 210.00, 1
FROM Categories c
WHERE c.category_name = 'Furniture'
UNION ALL
SELECT 'Ergonomic Chair', c.category_id, 280.00, 170.00, 1
FROM Categories c
WHERE c.category_name = 'Furniture'
UNION ALL
SELECT 'Printer Ink Pack', c.category_id, 45.00, 20.00, 1
FROM Categories c
WHERE c.category_name = 'Office Supplies'
UNION ALL
SELECT 'Notebook Set', c.category_id, 20.00, 8.00, 1
FROM Categories c
WHERE c.category_name = 'Office Supplies'
UNION ALL
SELECT 'Treadmill FitRun', c.category_id, 780.00, 560.00, 1
FROM Categories c
WHERE c.category_name = 'Fitness Equipment'
UNION ALL
SELECT 'Dumbbell Set 20kg', c.category_id, 140.00, 85.00, 1
FROM Categories c
WHERE c.category_name = 'Fitness Equipment';
GO

------------------------------------------------------------
-- 4. Insert Orders
------------------------------------------------------------
INSERT INTO Orders (customer_id, order_date, order_status, total_amount)
SELECT c.customer_id, '2025-04-01', 'Completed', 1380.00
FROM Customers c WHERE c.email = 'john.smith@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-02', 'Completed', 950.00
FROM Customers c WHERE c.email = 'emma.johnson@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-03', 'Completed', 220.00
FROM Customers c WHERE c.email = 'michael.brown@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-05', 'Completed', 600.00
FROM Customers c WHERE c.email = 'sophia.davis@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-07', 'Completed', 160.00
FROM Customers c WHERE c.email = 'daniel.wilson@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-10', 'Completed', 1100.00
FROM Customers c WHERE c.email = 'olivia.miller@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-12', 'Completed', 320.00
FROM Customers c WHERE c.email = 'james.moore@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-15', 'Completed', 200.00
FROM Customers c WHERE c.email = 'ava.taylor@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-18', 'Completed', 920.00
FROM Customers c WHERE c.email = 'william.anderson@email.com'
UNION ALL
SELECT c.customer_id, '2025-04-20', 'Completed', 300.00
FROM Customers c WHERE c.email = 'mia.thomas@email.com'
UNION ALL
SELECT c.customer_id, '2025-05-02', 'Completed', 140.00
FROM Customers c WHERE c.email = 'john.smith@email.com'
UNION ALL
SELECT c.customer_id, '2025-05-06', 'Completed', 180.00
FROM Customers c WHERE c.email = 'michael.brown@email.com'
UNION ALL
SELECT c.customer_id, '2025-05-10', 'Completed', 780.00
FROM Customers c WHERE c.email = 'daniel.wilson@email.com'
UNION ALL
SELECT c.customer_id, '2025-05-14', 'Completed', 65.00
FROM Customers c WHERE c.email = 'james.moore@email.com'
UNION ALL
SELECT c.customer_id, '2025-05-18', 'Completed', 280.00
FROM Customers c WHERE c.email = 'william.anderson@email.com'
UNION ALL
SELECT c.customer_id, '2025-05-20', 'Pending', 160.00
FROM Customers c WHERE c.email = 'emma.johnson@email.com'
UNION ALL
SELECT c.customer_id, '2025-05-25', 'Cancelled', 850.00
FROM Customers c WHERE c.email = 'sophia.davis@email.com';
GO

------------------------------------------------------------
-- 5. Insert Order Items
-- Match orders by customer + date, and products by name
------------------------------------------------------------

-- Order 1: John, 2025-04-01 = Laptop + Headphones
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 1200.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Laptop Pro 15'
WHERE c.email = 'john.smith@email.com'
  AND o.order_date = '2025-04-01';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 180.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Wireless Headphones'
WHERE c.email = 'john.smith@email.com'
  AND o.order_date = '2025-04-01';

-- Order 2
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 950.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Smartphone X'
WHERE c.email = 'emma.johnson@email.com'
  AND o.order_date = '2025-04-02';

-- Order 3
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 220.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Microwave Oven'
WHERE c.email = 'michael.brown@email.com'
  AND o.order_date = '2025-04-03';

-- Order 4
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 320.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Office Desk'
WHERE c.email = 'sophia.davis@email.com'
  AND o.order_date = '2025-04-05';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 280.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Ergonomic Chair'
WHERE c.email = 'sophia.davis@email.com'
  AND o.order_date = '2025-04-05';

-- Order 5
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 160.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Air Fryer Max'
WHERE c.email = 'daniel.wilson@email.com'
  AND o.order_date = '2025-04-07';

-- Order 6
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 850.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Luxury Sofa'
WHERE c.email = 'olivia.miller@email.com'
  AND o.order_date = '2025-04-10';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 140.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Dumbbell Set 20kg'
WHERE c.email = 'olivia.miller@email.com'
  AND o.order_date = '2025-04-10';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 2, 45.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Printer Ink Pack'
WHERE c.email = 'olivia.miller@email.com'
  AND o.order_date = '2025-04-10';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 20.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Notebook Set'
WHERE c.email = 'olivia.miller@email.com'
  AND o.order_date = '2025-04-10';

-- Order 7
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 320.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Office Desk'
WHERE c.email = 'james.moore@email.com'
  AND o.order_date = '2025-04-12';

-- Order 8
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 180.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Wireless Headphones'
WHERE c.email = 'ava.taylor@email.com'
  AND o.order_date = '2025-04-15';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 20.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Notebook Set'
WHERE c.email = 'ava.taylor@email.com'
  AND o.order_date = '2025-04-15';

-- Order 9
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 780.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Treadmill FitRun'
WHERE c.email = 'william.anderson@email.com'
  AND o.order_date = '2025-04-18';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 140.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Dumbbell Set 20kg'
WHERE c.email = 'william.anderson@email.com'
  AND o.order_date = '2025-04-18';

-- Order 10
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 280.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Ergonomic Chair'
WHERE c.email = 'mia.thomas@email.com'
  AND o.order_date = '2025-04-20';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 20.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Notebook Set'
WHERE c.email = 'mia.thomas@email.com'
  AND o.order_date = '2025-04-20';

-- Order 11
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 140.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Dumbbell Set 20kg'
WHERE c.email = 'john.smith@email.com'
  AND o.order_date = '2025-05-02';

-- Order 12
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 180.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Wireless Headphones'
WHERE c.email = 'michael.brown@email.com'
  AND o.order_date = '2025-05-06';

-- Order 13
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 780.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Treadmill FitRun'
WHERE c.email = 'daniel.wilson@email.com'
  AND o.order_date = '2025-05-10';

-- Order 14
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 45.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Printer Ink Pack'
WHERE c.email = 'james.moore@email.com'
  AND o.order_date = '2025-05-14';

INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 20.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Notebook Set'
WHERE c.email = 'james.moore@email.com'
  AND o.order_date = '2025-05-14';

-- Order 15
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 280.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Ergonomic Chair'
WHERE c.email = 'william.anderson@email.com'
  AND o.order_date = '2025-05-18';

-- Order 16
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 160.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Air Fryer Max'
WHERE c.email = 'emma.johnson@email.com'
  AND o.order_date = '2025-05-20';

-- Order 17
INSERT INTO Order_Items (order_id, product_id, quantity, selling_price)
SELECT o.order_id, p.product_id, 1, 850.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON p.product_name = 'Luxury Sofa'
WHERE c.email = 'sophia.davis@email.com'
  AND o.order_date = '2025-05-25';
GO

------------------------------------------------------------
-- 6. Insert Payments
-- Only for non-cancelled orders in this sample
------------------------------------------------------------
INSERT INTO Payments (order_id, payment_method, payment_date, payment_amount)
SELECT o.order_id, 'Credit Card', '2025-04-01', 1380.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'john.smith@email.com'
  AND o.order_date = '2025-04-01'
UNION ALL
SELECT o.order_id, 'PayPal', '2025-04-02', 950.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'emma.johnson@email.com'
  AND o.order_date = '2025-04-02'
UNION ALL
SELECT o.order_id, 'Debit Card', '2025-04-03', 220.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'michael.brown@email.com'
  AND o.order_date = '2025-04-03'
UNION ALL
SELECT o.order_id, 'Credit Card', '2025-04-05', 600.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'sophia.davis@email.com'
  AND o.order_date = '2025-04-05'
UNION ALL
SELECT o.order_id, 'PayPal', '2025-04-07', 160.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'daniel.wilson@email.com'
  AND o.order_date = '2025-04-07'
UNION ALL
SELECT o.order_id, 'Credit Card', '2025-04-10', 1100.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'olivia.miller@email.com'
  AND o.order_date = '2025-04-10'
UNION ALL
SELECT o.order_id, 'Bank Transfer', '2025-04-12', 320.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'james.moore@email.com'
  AND o.order_date = '2025-04-12'
UNION ALL
SELECT o.order_id, 'Debit Card', '2025-04-15', 200.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'ava.taylor@email.com'
  AND o.order_date = '2025-04-15'
UNION ALL
SELECT o.order_id, 'Credit Card', '2025-04-18', 920.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'william.anderson@email.com'
  AND o.order_date = '2025-04-18'
UNION ALL
SELECT o.order_id, 'PayPal', '2025-04-20', 300.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'mia.thomas@email.com'
  AND o.order_date = '2025-04-20'
UNION ALL
SELECT o.order_id, 'Debit Card', '2025-05-02', 140.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'john.smith@email.com'
  AND o.order_date = '2025-05-02'
UNION ALL
SELECT o.order_id, 'Credit Card', '2025-05-06', 180.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'michael.brown@email.com'
  AND o.order_date = '2025-05-06'
UNION ALL
SELECT o.order_id, 'Bank Transfer', '2025-05-10', 780.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'daniel.wilson@email.com'
  AND o.order_date = '2025-05-10'
UNION ALL
SELECT o.order_id, 'PayPal', '2025-05-14', 65.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'james.moore@email.com'
  AND o.order_date = '2025-05-14'
UNION ALL
SELECT o.order_id, 'Credit Card', '2025-05-18', 280.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'william.anderson@email.com'
  AND o.order_date = '2025-05-18'
UNION ALL
SELECT o.order_id, 'PayPal', '2025-05-20', 160.00
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.email = 'emma.johnson@email.com'
  AND o.order_date = '2025-05-20';
GO