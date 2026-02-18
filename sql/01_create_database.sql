/* =========================================================
   Create Data Warehouse Portfolio Database
========================================================= */

IF DB_ID('AdventureWorksDW_Portfolio') IS NULL
BEGIN
    CREATE DATABASE AdventureWorksDW_Portfolio;
    PRINT 'Database AdventureWorksDW_Portfolio created.';
END
ELSE
    PRINT 'Database already exists.';
GO
