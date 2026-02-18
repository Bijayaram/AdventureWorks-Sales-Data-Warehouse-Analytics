/* =========================================================
   File: sql/03_create_staging_tables.sql
   Target DB: AdventureWorksDW_Portfolio
   Source DB: AdventureWorks2025
   Purpose  : Create staging tables for Internet Sales DW
   Method   : SELECT INTO TOP (0) to clone datatypes from source
========================================================= */

USE AdventureWorksDW_Portfolio;
GO

-- Safety: make sure schemas exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg') EXEC('CREATE SCHEMA stg AUTHORIZATION dbo;');
GO

/* -----------------------------
   Helper pattern:
   - Drop staging table if exists
   - Create empty table with same columns/types from source (TOP 0)
   - Add ETL audit columns
------------------------------ */

-- 1) Sales Order Header
IF OBJECT_ID('stg.SalesOrderHeader', 'U') IS NOT NULL DROP TABLE stg.SalesOrderHeader;
SELECT TOP (0) *
INTO stg.SalesOrderHeader
FROM AdventureWorks2025.Sales.SalesOrderHeader;

ALTER TABLE stg.SalesOrderHeader ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_SOH_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 2) Sales Order Detail
IF OBJECT_ID('stg.SalesOrderDetail', 'U') IS NOT NULL
    DROP TABLE stg.SalesOrderDetail;
GO

CREATE TABLE stg.SalesOrderDetail
(
    SalesOrderID        INT NOT NULL,
    SalesOrderDetailID  INT NOT NULL,
    CarrierTrackingNumber NVARCHAR(25) NULL,
    OrderQty            SMALLINT NOT NULL,
    ProductID           INT NOT NULL,
    SpecialOfferID      INT NOT NULL,
    UnitPrice           MONEY NOT NULL,
    UnitPriceDiscount   MONEY NOT NULL,
    LineTotal           MONEY NOT NULL,
    rowguid             UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate        DATETIME NOT NULL,

    ETL_RunID           INT NULL,
    ETL_LoadedAt        DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_stg_SOD_SalesOrderID
ON stg.SalesOrderDetail (SalesOrderID);
GO

-- 3) Product
IF OBJECT_ID('stg.Product', 'U') IS NOT NULL DROP TABLE stg.Product;
SELECT TOP (0) *
INTO stg.Product
FROM AdventureWorks2025.Production.Product;

ALTER TABLE stg.Product ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_Product_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 4) ProductSubcategory
IF OBJECT_ID('stg.ProductSubcategory', 'U') IS NOT NULL DROP TABLE stg.ProductSubcategory;
SELECT TOP (0) *
INTO stg.ProductSubcategory
FROM AdventureWorks2025.Production.ProductSubcategory;

ALTER TABLE stg.ProductSubcategory ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_PSC_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 5) ProductCategory
IF OBJECT_ID('stg.ProductCategory', 'U') IS NOT NULL DROP TABLE stg.ProductCategory;
SELECT TOP (0) *
INTO stg.ProductCategory
FROM AdventureWorks2025.Production.ProductCategory;

ALTER TABLE stg.ProductCategory ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_PC_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 6) Customer
IF OBJECT_ID('stg.Customer', 'U') IS NOT NULL DROP TABLE stg.Customer;
SELECT TOP (0) *
INTO stg.Customer
FROM AdventureWorks2025.Sales.Customer;

ALTER TABLE stg.Customer ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_Customer_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 7) Person (for customer names)
-- 7) Person (explicit create because source has typed XML columns)
IF OBJECT_ID('stg.Person', 'U') IS NOT NULL
    DROP TABLE stg.Person;
GO

CREATE TABLE stg.Person
(
    BusinessEntityID      INT               NOT NULL,
    PersonType            NCHAR(2)           NOT NULL,
    NameStyle             BIT               NOT NULL,
    Title                 NVARCHAR(8)        NULL,
    FirstName             NVARCHAR(50)       NOT NULL,
    MiddleName            NVARCHAR(50)       NULL,
    LastName              NVARCHAR(50)       NOT NULL,
    Suffix                NVARCHAR(10)       NULL,
    EmailPromotion        INT               NOT NULL,
    rowguid               UNIQUEIDENTIFIER  NOT NULL,
    ModifiedDate          DATETIME          NOT NULL,

    ETL_RunID             INT               NULL,
    ETL_LoadedAt          DATETIME2(0)      NOT NULL
        CONSTRAINT DF_stg_Person_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_stg_Person_BusinessEntityID
ON stg.Person (BusinessEntityID);
GO


-- 8) Address
IF OBJECT_ID('stg.Address', 'U') IS NOT NULL DROP TABLE stg.Address;
SELECT TOP (0) *
INTO stg.Address
FROM AdventureWorks2025.Person.Address;

ALTER TABLE stg.Address ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_Address_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 9) StateProvince
IF OBJECT_ID('stg.StateProvince', 'U') IS NOT NULL DROP TABLE stg.StateProvince;
SELECT TOP (0) *
INTO stg.StateProvince
FROM AdventureWorks2025.Person.StateProvince;

ALTER TABLE stg.StateProvince ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_StateProv_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 10) CountryRegion
IF OBJECT_ID('stg.CountryRegion', 'U') IS NOT NULL DROP TABLE stg.CountryRegion;
SELECT TOP (0) *
INTO stg.CountryRegion
FROM AdventureWorks2025.Person.CountryRegion;

ALTER TABLE stg.CountryRegion ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_Country_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- 11) SalesTerritory
IF OBJECT_ID('stg.SalesTerritory', 'U') IS NOT NULL DROP TABLE stg.SalesTerritory;
SELECT TOP (0) *
INTO stg.SalesTerritory
FROM AdventureWorks2025.Sales.SalesTerritory;

ALTER TABLE stg.SalesTerritory ADD
    ETL_RunID     INT           NULL,
    ETL_LoadedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_stg_Territory_LoadedAt DEFAULT SYSUTCDATETIME();
GO

-- (Optional but useful) Indexes to speed up joins later
CREATE INDEX IX_stg_SalesOrderHeader_SalesOrderID ON stg.SalesOrderHeader (SalesOrderID);
CREATE INDEX IX_stg_SalesOrderDetail_SalesOrderID ON stg.SalesOrderDetail (SalesOrderID);
CREATE INDEX IX_stg_SalesOrderDetail_ProductID    ON stg.SalesOrderDetail (ProductID);
CREATE INDEX IX_stg_Product_ProductID             ON stg.Product (ProductID);
CREATE INDEX IX_stg_Customer_CustomerID           ON stg.Customer (CustomerID);
GO

-- Verify tables exist
SELECT s.name AS SchemaName, t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = 'stg'
ORDER BY t.name;
GO
