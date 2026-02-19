USE AdventureWorksDW_Portfolio;
GO

/* 1) Drop the current staging table (the one with IDENTITY) */
IF OBJECT_ID('stg.SalesOrderHeader', 'U') IS NOT NULL
    DROP TABLE stg.SalesOrderHeader;
GO

/* 2) Recreate it explicitly WITHOUT identity */
CREATE TABLE stg.SalesOrderHeader
(
    SalesOrderID        INT NOT NULL,
    RevisionNumber      TINYINT NOT NULL,
    OrderDate           DATETIME NOT NULL,
    DueDate             DATETIME NOT NULL,
    ShipDate            DATETIME NULL,
    Status              TINYINT NOT NULL,
    OnlineOrderFlag     BIT NOT NULL,
    SalesOrderNumber    NVARCHAR(25) NOT NULL,
    PurchaseOrderNumber NVARCHAR(25) NULL,
    AccountNumber       NVARCHAR(15) NULL,
    CustomerID          INT NOT NULL,
    SalesPersonID       INT NULL,
    TerritoryID         INT NULL,
    BillToAddressID     INT NOT NULL,
    ShipToAddressID     INT NOT NULL,
    ShipMethodID        INT NOT NULL,
    CreditCardID        INT NULL,
    CreditCardApprovalCode NVARCHAR(15) NULL,
    CurrencyRateID      INT NULL,
    SubTotal            MONEY NOT NULL,
    TaxAmt              MONEY NOT NULL,
    Freight             MONEY NOT NULL,
    TotalDue            MONEY NOT NULL,
    Comment             NVARCHAR(128) NULL,
    rowguid             UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate        DATETIME NOT NULL,

    ETL_RunID           INT NULL,
    ETL_LoadedAt        DATETIME2(0) NOT NULL CONSTRAINT DF_stg_SOH_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_stg_SOH_SalesOrderID ON stg.SalesOrderHeader (SalesOrderID);
GO

/* 3) Verify: should return ZERO rows now */
SELECT c.name, c.is_identity
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name='stg' AND t.name='SalesOrderHeader' AND c.is_identity=1;
GO
