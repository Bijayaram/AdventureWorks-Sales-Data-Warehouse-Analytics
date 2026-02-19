USE AdventureWorksDW_Portfolio;
GO

INSERT INTO dw.FactInternetSales
(
    SalesOrderID, SalesOrderDetailID,
    OrderDateKey, DueDateKey, ShipDateKey,
    ProductKey, CustomerKey, SalesTerritoryKey,
    OrderQty, UnitPrice, UnitPriceDiscount, LineTotal,
    SubTotal, TaxAmt, Freight, TotalDue,
    ETL_RunID
)
SELECT
    sod.SalesOrderID,
    sod.SalesOrderDetailID,

    CONVERT(INT, FORMAT(CAST(soh.OrderDate AS DATE), 'yyyyMMdd')) AS OrderDateKey,
    CONVERT(INT, FORMAT(CAST(soh.DueDate   AS DATE), 'yyyyMMdd')) AS DueDateKey,
    CASE WHEN soh.ShipDate IS NULL THEN NULL
         ELSE CONVERT(INT, FORMAT(CAST(soh.ShipDate AS DATE), 'yyyyMMdd'))
    END AS ShipDateKey,

    dp.ProductKey,
    dc.CustomerKey,
    dst.SalesTerritoryKey,

    sod.OrderQty,
    sod.UnitPrice,
    sod.UnitPriceDiscount,
    sod.LineTotal,

    soh.SubTotal,
    soh.TaxAmt,
    soh.Freight,
    soh.TotalDue,

    MAX(sod.ETL_RunID) AS ETL_RunID
FROM stg.SalesOrderDetail sod
JOIN stg.SalesOrderHeader soh
    ON sod.SalesOrderID = soh.SalesOrderID

-- Map to dimensions (surrogate keys)
JOIN dw.DimProduct dp
    ON dp.ProductID = sod.ProductID

JOIN dw.DimCustomer dc
    ON dc.CustomerID = soh.CustomerID
   AND dc.IsCurrent = 1

LEFT JOIN dw.DimSalesTerritory dst
    ON dst.TerritoryID = soh.TerritoryID

GROUP BY
    sod.SalesOrderID, sod.SalesOrderDetailID,
    CAST(soh.OrderDate AS DATE), CAST(soh.DueDate AS DATE), CAST(soh.ShipDate AS DATE),
    dp.ProductKey, dc.CustomerKey, dst.SalesTerritoryKey,
    sod.OrderQty, sod.UnitPrice, sod.UnitPriceDiscount, sod.LineTotal,
    soh.SubTotal, soh.TaxAmt, soh.Freight, soh.TotalDue;
GO
