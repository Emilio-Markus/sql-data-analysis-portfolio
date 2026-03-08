USE RetailSalesDB;
GO

/* Drop child tables first if re-running */
IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.Order_Items', 'U') IS NOT NULL DROP TABLE dbo.Order_Items;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
GO

--creating the tables in the DB

CREATE TABLE Customers (
    customer_id      INT IDENTITY(1,1) PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    city             VARCHAR(50) NOT NULL,
    country          VARCHAR(50) NOT NULL,
    signup_date      DATE NOT NULL
);
GO

CREATE TABLE Categories (
    category_id      INT IDENTITY(1,1) PRIMARY KEY,
    category_name    VARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE Products (
    product_id       INT IDENTITY(1,1) PRIMARY KEY,
    product_name     VARCHAR(100) NOT NULL,
    category_id      INT NOT NULL,
    unit_price       DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    cost_price       DECIMAL(10,2) NOT NULL CHECK (cost_price >= 0),
    is_active        BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);
GO

CREATE TABLE Orders (
    order_id         INT IDENTITY(1,1) PRIMARY KEY,
    customer_id      INT NOT NULL,
    order_date       DATE NOT NULL,
    order_status     VARCHAR(20) NOT NULL DEFAULT 'Completed'
        CHECK (order_status IN ('Completed', 'Pending', 'Cancelled')),
    total_amount     DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
GO

CREATE TABLE Order_Items (
    order_item_id    INT IDENTITY(1,1) PRIMARY KEY,
    order_id         INT NOT NULL,
    product_id       INT NOT NULL,
    quantity         INT NOT NULL CHECK (quantity > 0),
    selling_price    DECIMAL(10,2) NOT NULL CHECK (selling_price >= 0),
    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
GO

CREATE TABLE Payments (
    payment_id       INT IDENTITY(1,1) PRIMARY KEY,
    order_id         INT NOT NULL,
    payment_method   VARCHAR(50) NOT NULL,
    payment_date     DATE NOT NULL,
    payment_amount   DECIMAL(10,2) NOT NULL CHECK (payment_amount >= 0),
    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);
GO