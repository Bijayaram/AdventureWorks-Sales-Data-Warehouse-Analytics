USE AdventureWorksDW_Portfolio;
GO

IF OBJECT_ID('dw.DimCustomer','U') IS NOT NULL
    DROP TABLE dw.DimCustomer;
GO

CREATE TABLE dw.DimCustomer
(
    CustomerKey         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,  -- surrogate key
    CustomerID          INT NOT NULL,                              -- business key

    FullName            NVARCHAR(160) NULL,
    PersonID            INT NULL,
    TerritoryID         INT NULL,

    AddressLine1        NVARCHAR(60) NULL,
    AddressLine2        NVARCHAR(60) NULL,
    City                NVARCHAR(30) NULL,
    StateProvinceName   NVARCHAR(50) NULL,
    CountryRegionCode   NVARCHAR(3)  NULL,
    PostalCode          NVARCHAR(15) NULL,

    -- SCD Type 2 tracking
    StartDate           DATE NOT NULL,
    EndDate             DATE NOT NULL,
    IsCurrent           BIT  NOT NULL,

    -- Change detection hash (makes comparison easy)
    RowHash             VARBINARY(32) NOT NULL,

    ETL_RunID           INT NULL,
    ETL_LoadedAt        DATETIME2(0) NOT NULL CONSTRAINT DF_DimCustomer_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

-- Helpful indexes
CREATE INDEX IX_DimCustomer_CustomerID_Current ON dw.DimCustomer(CustomerID, IsCurrent);
GO
