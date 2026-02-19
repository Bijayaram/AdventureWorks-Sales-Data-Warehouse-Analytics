USE AdventureWorksDW_Portfolio;
GO

IF OBJECT_ID('dw.FactInternetSales','U') IS NOT NULL
    DROP TABLE dw.FactInternetSales;
GO

CREATE TABLE dw.FactInternetSales
(
    FactInternetSalesKey BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    SalesOrderID         INT NOT NULL,
    SalesOrderDetailID   INT NOT NULL,

    OrderDateKey         INT NOT NULL,
    DueDateKey           INT NOT NULL,
    ShipDateKey          INT NULL,

    ProductKey           INT NOT NULL,
    CustomerKey          INT NOT NULL,
    SalesTerritoryKey    INT NULL,

    OrderQty             SMALLINT NOT NULL,
    UnitPrice            MONEY NOT NULL,
    UnitPriceDiscount    MONEY NOT NULL,
    LineTotal            MONEY NOT NULL,

    SubTotal             MONEY NOT NULL,
    TaxAmt               MONEY NOT NULL,
    Freight              MONEY NOT NULL,
    TotalDue             MONEY NOT NULL,

    ETL_RunID             INT NULL,
    ETL_LoadedAt          DATETIME2(0) NOT NULL CONSTRAINT DF_FactInternetSales_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

-- Prevent duplicate loads (natural grain key)
CREATE UNIQUE INDEX UX_FactInternetSales_Grain
ON dw.FactInternetSales (SalesOrderID, SalesOrderDetailID);
GO

-- Helpful join indexes
CREATE INDEX IX_Fact_OrderDateKey ON dw.FactInternetSales(OrderDateKey);
CREATE INDEX IX_Fact_ProductKey   ON dw.FactInternetSales(ProductKey);
CREATE INDEX IX_Fact_CustomerKey  ON dw.FactInternetSales(CustomerKey);
GO
