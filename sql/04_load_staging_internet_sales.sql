/* =========================================================
   File: sql/04_load_staging_internet_sales.sql
   Target DB: AdventureWorksDW_Portfolio
   Source DB: AdventureWorks2025
   Purpose  : Load stg tables from AdventureWorks2025 (full refresh)
              + log run details in etl.RunLog
   Notes    :
     - stg.Person is loaded with an explicit column list because the
       source table has typed XML columns we excluded from staging.
========================================================= */

USE AdventureWorksDW_Portfolio;
GO

CREATE OR ALTER PROCEDURE etl.usp_LoadStaging_InternetSales
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @RunID        INT = NULL,
        @RowsInserted INT = 0;

    BEGIN TRY
        /* 1) Start RunLog */
        INSERT INTO etl.RunLog (PipelineName)
        VALUES ('Load_Staging_InternetSales');

        SET @RunID = SCOPE_IDENTITY();

        /* 2) Clear staging (full refresh) */
        TRUNCATE TABLE stg.SalesOrderDetail;
        TRUNCATE TABLE stg.SalesOrderHeader;
        TRUNCATE TABLE stg.Product;
        TRUNCATE TABLE stg.ProductSubcategory;
        TRUNCATE TABLE stg.ProductCategory;
        TRUNCATE TABLE stg.Customer;
        TRUNCATE TABLE stg.Person;
        TRUNCATE TABLE stg.Address;
        TRUNCATE TABLE stg.StateProvince;
        TRUNCATE TABLE stg.CountryRegion;
        TRUNCATE TABLE stg.SalesTerritory;

        /* 3) Load staging tables from source */
        INSERT INTO stg.SalesOrderHeader
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Sales.SalesOrderHeader;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.SalesOrderDetail
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Sales.SalesOrderDetail;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.Product
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Production.Product;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.ProductSubcategory
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Production.ProductSubcategory;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.ProductCategory
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Production.ProductCategory;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.Customer
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Sales.Customer;
        SET @RowsInserted += @@ROWCOUNT;

        /* Person (explicit list; excludes typed XML columns) */
        INSERT INTO stg.Person
        (
            BusinessEntityID, PersonType, NameStyle, Title,
            FirstName, MiddleName, LastName, Suffix,
            EmailPromotion, rowguid, ModifiedDate,
            ETL_RunID, ETL_LoadedAt
        )
        SELECT
            BusinessEntityID, PersonType, NameStyle, Title,
            FirstName, MiddleName, LastName, Suffix,
            EmailPromotion, rowguid, ModifiedDate,
            @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Person.Person;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.Address
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Person.Address;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.StateProvince
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Person.StateProvince;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.CountryRegion
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Person.CountryRegion;
        SET @RowsInserted += @@ROWCOUNT;

        INSERT INTO stg.SalesTerritory
        SELECT *, @RunID, SYSUTCDATETIME()
        FROM AdventureWorks2025.Sales.SalesTerritory;
        SET @RowsInserted += @@ROWCOUNT;

        /* 4) Mark success */
        UPDATE etl.RunLog
        SET Status       = 'Success',
            EndTime      = SYSUTCDATETIME(),
            RowsInserted = @RowsInserted
        WHERE RunID = @RunID;

        SELECT @RunID AS RunID, @RowsInserted AS TotalRowsInserted;
    END TRY
    BEGIN CATCH
        DECLARE
            @ErrNum INT = ERROR_NUMBER(),
            @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();

        IF @RunID IS NOT NULL
        BEGIN
            UPDATE etl.RunLog
            SET Status       = 'Failed',
                EndTime      = SYSUTCDATETIME(),
                ErrorNumber  = @ErrNum,
                ErrorMessage = @ErrMsg
            WHERE RunID = @RunID;
        END

        ;THROW;  -- <-- fixed (leading semicolon)
    END CATCH
END;
GO
