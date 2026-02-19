USE AdventureWorksDW_Portfolio;
GO

CREATE OR ALTER PROCEDURE etl.usp_LoadDimCustomer_SCD2
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @RunID INT = NULL,
        @Today DATE = CAST(GETDATE() AS DATE);

    BEGIN TRY
        -- Log start
        INSERT INTO etl.RunLog (PipelineName)
        VALUES ('Load_dw_DimCustomer_SCD2');

        SET @RunID = SCOPE_IDENTITY();

        ;WITH LatestCustomerAddress AS
        (
            SELECT
                soh.CustomerID,
                soh.BillToAddressID,
                ROW_NUMBER() OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate DESC, soh.SalesOrderID DESC) AS rn
            FROM stg.SalesOrderHeader soh
        ),
        CustomerBase AS
        (
            SELECT
                c.CustomerID,
                c.PersonID,
                c.TerritoryID,
                p.FirstName,
                p.MiddleName,
                p.LastName,
                a.AddressLine1,
                a.AddressLine2,
                a.City,
                sp.Name AS StateProvinceName,
                sp.CountryRegionCode,
                a.PostalCode
            FROM stg.Customer c
            LEFT JOIN stg.Person p
                ON c.PersonID = p.BusinessEntityID
            LEFT JOIN LatestCustomerAddress lca
                ON c.CustomerID = lca.CustomerID AND lca.rn = 1
            LEFT JOIN stg.Address a
                ON lca.BillToAddressID = a.AddressID
            LEFT JOIN stg.StateProvince sp
                ON a.StateProvinceID = sp.StateProvinceID
        ),
        CustomerWithName AS
        (
            SELECT
                CustomerID,
                PersonID,
                TerritoryID,
                LTRIM(RTRIM(
                    COALESCE(FirstName,'') + ' ' +
                    COALESCE(NULLIF(MiddleName,'' ) + ' ', '') +
                    COALESCE(LastName,'')
                )) AS FullName,
                AddressLine1, AddressLine2, City,
                StateProvinceName, CountryRegionCode, PostalCode
            FROM CustomerBase
        ),
        CustomerSrc AS
        (
            SELECT
                CustomerID,
                PersonID,
                TerritoryID,
                FullName,
                AddressLine1, AddressLine2, City,
                StateProvinceName, CountryRegionCode, PostalCode,

                HASHBYTES('SHA2_256', CONCAT(
                    COALESCE(CONVERT(NVARCHAR(20), PersonID), ''),
                    '|', COALESCE(CONVERT(NVARCHAR(20), TerritoryID), ''),
                    '|', COALESCE(FullName,''),
                    '|', COALESCE(AddressLine1,''),
                    '|', COALESCE(AddressLine2,''),
                    '|', COALESCE(City,''),
                    '|', COALESCE(StateProvinceName,''),
                    '|', COALESCE(CountryRegionCode,''),
                    '|', COALESCE(PostalCode,'')
                )) AS RowHash
            FROM CustomerWithName
        )

        -- 1) Close out changed current rows
        UPDATE d
        SET
            d.EndDate   = DATEADD(DAY, -1, @Today),
            d.IsCurrent = 0,
            d.ETL_RunID = @RunID
        FROM dw.DimCustomer d
        JOIN CustomerSrc s
            ON d.CustomerID = s.CustomerID
        WHERE d.IsCurrent = 1
          AND d.RowHash <> s.RowHash;

        -- 2) Insert new rows (new customers or changed customers)
        INSERT INTO dw.DimCustomer
        (
            CustomerID, FullName, PersonID, TerritoryID,
            AddressLine1, AddressLine2, City, StateProvinceName,
            CountryRegionCode, PostalCode,
            StartDate, EndDate, IsCurrent,
            RowHash, ETL_RunID
        )
        SELECT
            s.CustomerID, s.FullName, s.PersonID, s.TerritoryID,
            s.AddressLine1, s.AddressLine2, s.City, s.StateProvinceName,
            s.CountryRegionCode, s.PostalCode,
            @Today, '9999-12-31', 1,
            s.RowHash, @RunID
        FROM CustomerSrc s
        LEFT JOIN dw.DimCustomer d
            ON d.CustomerID = s.CustomerID AND d.IsCurrent = 1
        WHERE d.CustomerID IS NULL
           OR d.RowHash <> s.RowHash;

        -- Mark success
        UPDATE etl.RunLog
        SET Status  = 'Success',
            EndTime = SYSUTCDATETIME()
        WHERE RunID = @RunID;

        SELECT @RunID AS RunID;
    END TRY
    BEGIN CATCH
        DECLARE
            @ErrNum INT = ERROR_NUMBER(),
            @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();

        IF @RunID IS NOT NULL
        BEGIN
            UPDATE etl.RunLog
            SET Status = 'Failed',
                EndTime = SYSUTCDATETIME(),
                ErrorNumber = @ErrNum,
                ErrorMessage = @ErrMsg
            WHERE RunID = @RunID;
        END

        ;THROW;
    END CATCH
END;
GO
