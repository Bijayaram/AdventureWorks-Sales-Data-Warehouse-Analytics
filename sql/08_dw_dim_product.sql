USE AdventureWorksDW_Portfolio;
GO

IF OBJECT_ID('dw.DimProduct','U') IS NOT NULL
    DROP TABLE dw.DimProduct;
GO

CREATE TABLE dw.DimProduct
(
    ProductKey            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,  -- surrogate key
    ProductID             INT NOT NULL,                             -- business key from source

    ProductName           NVARCHAR(50) NOT NULL,
    ProductNumber         NVARCHAR(25) NOT NULL,
    Color                 NVARCHAR(15) NULL,
    Size                  NVARCHAR(5)  NULL,
    StandardCost          MONEY NOT NULL,
    ListPrice             MONEY NOT NULL,

    ProductSubcategoryID  INT NULL,
    ProductSubcategory    NVARCHAR(50) NULL,

    ProductCategoryID     INT NULL,
    ProductCategory       NVARCHAR(50) NULL,

    SellStartDate         DATE NOT NULL,
    SellEndDate           DATE NULL,
    ModifiedDate          DATETIME NOT NULL,

    ETL_RunID             INT NULL,
    ETL_LoadedAt          DATETIME2(0) NOT NULL CONSTRAINT DF_DimProduct_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

-- Helpful indexes for lookups/joins
CREATE UNIQUE INDEX UX_DimProduct_ProductID ON dw.DimProduct(ProductID);
CREATE INDEX IX_DimProduct_Category ON dw.DimProduct(ProductCategoryID);
GO
