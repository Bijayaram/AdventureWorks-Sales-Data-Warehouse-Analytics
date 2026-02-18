USE AdventureWorksDW_Portfolio;
GO

IF OBJECT_ID('stg.Product', 'U') IS NOT NULL
    DROP TABLE stg.Product;
GO

CREATE TABLE stg.Product
(
    ProductID              INT NOT NULL,
    Name                   NVARCHAR(50) NOT NULL,
    ProductNumber          NVARCHAR(25) NOT NULL,
    MakeFlag               BIT NOT NULL,
    FinishedGoodsFlag      BIT NOT NULL,
    Color                  NVARCHAR(15) NULL,
    SafetyStockLevel       SMALLINT NOT NULL,
    ReorderPoint           SMALLINT NOT NULL,
    StandardCost           MONEY NOT NULL,
    ListPrice              MONEY NOT NULL,
    Size                   NVARCHAR(5) NULL,
    SizeUnitMeasureCode    NCHAR(3) NULL,
    WeightUnitMeasureCode  NCHAR(3) NULL,
    Weight                 DECIMAL(8,2) NULL,
    DaysToManufacture      INT NOT NULL,
    ProductLine            NCHAR(2) NULL,
    Class                  NCHAR(2) NULL,
    Style                  NCHAR(2) NULL,
    ProductSubcategoryID   INT NULL,
    ProductModelID         INT NULL,
    SellStartDate          DATETIME NOT NULL,
    SellEndDate            DATETIME NULL,
    DiscontinuedDate       DATETIME NULL,
    rowguid                UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate           DATETIME NOT NULL,

    ETL_RunID              INT NULL,
    ETL_LoadedAt           DATETIME2(0) NOT NULL CONSTRAINT DF_stg_Product_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_stg_Product_ProductID ON stg.Product(ProductID);
CREATE INDEX IX_stg_Product_SubcatID  ON stg.Product(ProductSubcategoryID);
GO

-- Verify identity is gone (should return 0 rows)
SELECT c.name, c.is_identity
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name='stg' AND t.name='Product' AND c.is_identity=1;
GO
