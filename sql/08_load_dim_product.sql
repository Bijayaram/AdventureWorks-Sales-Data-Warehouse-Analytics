USE AdventureWorksDW_Portfolio;
GO

INSERT INTO dw.DimProduct
(
    ProductID, ProductName, ProductNumber, Color, Size,
    StandardCost, ListPrice,
    ProductSubcategoryID, ProductSubcategory,
    ProductCategoryID, ProductCategory,
    SellStartDate, SellEndDate, ModifiedDate,
    ETL_RunID
)
SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.ProductNumber,
    p.Color,
    p.Size,
    p.StandardCost,
    p.ListPrice,
    p.ProductSubcategoryID,
    sc.Name AS ProductSubcategory,
    sc.ProductCategoryID,
    c.Name AS ProductCategory,
    CAST(p.SellStartDate AS DATE) AS SellStartDate,
    CAST(p.SellEndDate AS DATE) AS SellEndDate,
    p.ModifiedDate,
    MAX(p.ETL_RunID) AS ETL_RunID
FROM stg.Product p
LEFT JOIN stg.ProductSubcategory sc
    ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN stg.ProductCategory c
    ON sc.ProductCategoryID = c.ProductCategoryID
GROUP BY
    p.ProductID, p.Name, p.ProductNumber, p.Color, p.Size,
    p.StandardCost, p.ListPrice,
    p.ProductSubcategoryID, sc.Name,
    sc.ProductCategoryID, c.Name,
    CAST(p.SellStartDate AS DATE), CAST(p.SellEndDate AS DATE),
    p.ModifiedDate;
GO
