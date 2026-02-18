USE AdventureWorksDW_Portfolio;
GO

/* =========================================================
   Fix staging tables that accidentally copied IDENTITY from
   AdventureWorks2025 via SELECT INTO.
   We drop and recreate WITHOUT identity.
========================================================= */

------------------------------------------------------------
-- stg.Address
------------------------------------------------------------
IF OBJECT_ID('stg.Address','U') IS NOT NULL DROP TABLE stg.Address;
GO

CREATE TABLE stg.Address
(
    AddressID       INT NOT NULL,
    AddressLine1    NVARCHAR(60) NOT NULL,
    AddressLine2    NVARCHAR(60) NULL,
    City            NVARCHAR(30) NOT NULL,
    StateProvinceID INT NOT NULL,
    PostalCode      NVARCHAR(15) NOT NULL,
    SpatialLocation GEOGRAPHY NULL,
    rowguid         UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate    DATETIME NOT NULL,

    ETL_RunID        INT NULL,
    ETL_LoadedAt     DATETIME2(0) NOT NULL CONSTRAINT DF_stg_Address_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX IX_stg_Address_AddressID ON stg.Address(AddressID);
CREATE INDEX IX_stg_Address_StateProvinceID ON stg.Address(StateProvinceID);
GO


------------------------------------------------------------
-- stg.Customer
------------------------------------------------------------
IF OBJECT_ID('stg.Customer','U') IS NOT NULL DROP TABLE stg.Customer;
GO

CREATE TABLE stg.Customer
(
    CustomerID    INT NOT NULL,
    PersonID      INT NULL,
    StoreID       INT NULL,
    TerritoryID   INT NULL,
    AccountNumber NVARCHAR(10) NOT NULL,
    rowguid       UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate  DATETIME NOT NULL,

    ETL_RunID     INT NULL,
    ETL_LoadedAt  DATETIME2(0) NOT NULL CONSTRAINT DF_stg_Customer_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX IX_stg_Customer_CustomerID ON stg.Customer(CustomerID);
CREATE INDEX IX_stg_Customer_PersonID   ON stg.Customer(PersonID);
CREATE INDEX IX_stg_Customer_TerritoryID ON stg.Customer(TerritoryID);
GO


------------------------------------------------------------
-- stg.ProductCategory
------------------------------------------------------------
IF OBJECT_ID('stg.ProductCategory','U') IS NOT NULL DROP TABLE stg.ProductCategory;
GO

CREATE TABLE stg.ProductCategory
(
    ProductCategoryID INT NOT NULL,
    Name              NVARCHAR(50) NOT NULL,
    rowguid           UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate      DATETIME NOT NULL,

    ETL_RunID         INT NULL,
    ETL_LoadedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_stg_PC_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX IX_stg_ProductCategory_ID ON stg.ProductCategory(ProductCategoryID);
GO


------------------------------------------------------------
-- stg.ProductSubcategory
------------------------------------------------------------
IF OBJECT_ID('stg.ProductSubcategory','U') IS NOT NULL DROP TABLE stg.ProductSubcategory;
GO

CREATE TABLE stg.ProductSubcategory
(
    ProductSubcategoryID INT NOT NULL,
    ProductCategoryID    INT NOT NULL,
    Name                 NVARCHAR(50) NOT NULL,
    rowguid              UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate         DATETIME NOT NULL,

    ETL_RunID            INT NULL,
    ETL_LoadedAt         DATETIME2(0) NOT NULL CONSTRAINT DF_stg_PSC_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX IX_stg_ProductSubcategory_ID ON stg.ProductSubcategory(ProductSubcategoryID);
CREATE INDEX IX_stg_ProductSubcategory_CatID ON stg.ProductSubcategory(ProductCategoryID);
GO


------------------------------------------------------------
-- stg.SalesTerritory
------------------------------------------------------------
IF OBJECT_ID('stg.SalesTerritory','U') IS NOT NULL DROP TABLE stg.SalesTerritory;
GO

CREATE TABLE stg.SalesTerritory
(
    TerritoryID       INT NOT NULL,
    Name              NVARCHAR(50) NOT NULL,
    CountryRegionCode NVARCHAR(3)  NOT NULL,
    [Group]           NVARCHAR(50) NOT NULL,
    SalesYTD          MONEY NOT NULL,
    SalesLastYear     MONEY NOT NULL,
    CostYTD           MONEY NOT NULL,
    CostLastYear      MONEY NOT NULL,
    rowguid           UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate      DATETIME NOT NULL,

    ETL_RunID         INT NULL,
    ETL_LoadedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_stg_Territory_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX IX_stg_SalesTerritory_ID ON stg.SalesTerritory(TerritoryID);
GO


------------------------------------------------------------
-- stg.StateProvince
------------------------------------------------------------
IF OBJECT_ID('stg.StateProvince','U') IS NOT NULL DROP TABLE stg.StateProvince;
GO

CREATE TABLE stg.StateProvince
(
    StateProvinceID         INT NOT NULL,
    StateProvinceCode       NCHAR(3) NOT NULL,
    CountryRegionCode       NVARCHAR(3) NOT NULL,
    IsOnlyStateProvinceFlag BIT NOT NULL,
    Name                    NVARCHAR(50) NOT NULL,
    TerritoryID             INT NOT NULL,
    rowguid                 UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate            DATETIME NOT NULL,

    ETL_RunID               INT NULL,
    ETL_LoadedAt            DATETIME2(0) NOT NULL CONSTRAINT DF_stg_StateProv_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO
CREATE INDEX IX_stg_StateProvince_ID ON stg.StateProvince(StateProvinceID);
CREATE INDEX IX_stg_StateProvince_TerritoryID ON stg.StateProvince(TerritoryID);
GO


/* =========================================================
   Verification: should return 0 rows if all fixed
========================================================= */
SELECT t.name AS TableName, c.name AS IdentityColumn
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.columns c ON c.object_id = t.object_id
WHERE s.name='stg' AND c.is_identity=1
ORDER BY t.name;
GO
