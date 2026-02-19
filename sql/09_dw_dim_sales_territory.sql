USE AdventureWorksDW_Portfolio;
GO

IF OBJECT_ID('dw.DimSalesTerritory','U') IS NOT NULL
    DROP TABLE dw.DimSalesTerritory;
GO

CREATE TABLE dw.DimSalesTerritory
(
    SalesTerritoryKey   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,  -- surrogate key
    TerritoryID         INT NOT NULL,                             -- business key

    TerritoryName       NVARCHAR(50) NOT NULL,
    CountryRegionCode   NVARCHAR(3)  NOT NULL,
    TerritoryGroup      NVARCHAR(50) NOT NULL,

    SalesYTD            MONEY NOT NULL,
    SalesLastYear       MONEY NOT NULL,
    CostYTD             MONEY NOT NULL,
    CostLastYear        MONEY NOT NULL,

    ModifiedDate        DATETIME NOT NULL,

    ETL_RunID           INT NULL,
    ETL_LoadedAt        DATETIME2(0) NOT NULL CONSTRAINT DF_DimTerritory_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE UNIQUE INDEX UX_DimSalesTerritory_TerritoryID ON dw.DimSalesTerritory(TerritoryID);
GO
