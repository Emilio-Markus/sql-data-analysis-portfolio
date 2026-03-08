-- Create the project database

IF DB_ID('RetailSalesDB') IS NOT NULL
BEGIN
    PRINT 'Database RetailSalesDB already exists.';
END
ELSE
BEGIN
    CREATE DATABASE RetailSalesDB;
    PRINT 'Database RetailSalesDB created successfully.';
END;
GO

USE RetailSalesDB;
GO