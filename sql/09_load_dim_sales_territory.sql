USE AdventureWorksDW_Portfolio;
GO

INSERT INTO dw.DimSalesTerritory
(
    TerritoryID, TerritoryName, CountryRegionCode, TerritoryGroup,
    SalesYTD, SalesLastYear, CostYTD, CostLastYear,
    ModifiedDate, ETL_RunID
)
SELECT
    TerritoryID,
    Name AS TerritoryName,
    CountryRegionCode,
    [Group] AS TerritoryGroup,
    SalesYTD, SalesLastYear, CostYTD, CostLastYear,
    ModifiedDate,
    MAX(ETL_RunID) AS ETL_RunID
FROM stg.SalesTerritory
GROUP BY
    TerritoryID, Name, CountryRegionCode, [Group],
    SalesYTD, SalesLastYear, CostYTD, CostLastYear,
    ModifiedDate;
GO
