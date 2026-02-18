USE AdventureWorksDW_Portfolio;
GO

IF OBJECT_ID('stg.SalesOrderHeader', 'U') IS NOT NULL
    DROP TABLE stg.SalesOrderHeader;
GO

-- Explicit create WITHOUT identity
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
    ETL_LoadedAt        DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_stg_SOH_SalesOrderID 
ON stg.SalesOrderHeader (SalesOrderID);
GO
