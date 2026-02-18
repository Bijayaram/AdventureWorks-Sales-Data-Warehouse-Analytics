USE AdventureWorksDW_Portfolio;
GO

-- Drop if partially created
IF OBJECT_ID('stg.Person', 'U') IS NOT NULL
    DROP TABLE stg.Person;
GO

/* Create stg.Person explicitly (excluding typed XML columns) */
CREATE TABLE stg.Person
(
    BusinessEntityID      INT           NOT NULL,
    PersonType            NCHAR(2)       NOT NULL,
    NameStyle             BIT           NOT NULL,
    Title                 NVARCHAR(8)    NULL,
    FirstName             NVARCHAR(50)   NOT NULL,
    MiddleName            NVARCHAR(50)   NULL,
    LastName              NVARCHAR(50)   NOT NULL,
    Suffix                NVARCHAR(10)   NULL,
    EmailPromotion        INT           NOT NULL,
    -- Excluded:
    -- AdditionalContactInfo XML (typed)
    -- Demographics         XML (typed)

    rowguid               UNIQUEIDENTIFIER NOT NULL,
    ModifiedDate          DATETIME        NOT NULL,

    ETL_RunID             INT            NULL,
    ETL_LoadedAt          DATETIME2(0)   NOT NULL CONSTRAINT DF_stg_Person_LoadedAt DEFAULT SYSUTCDATETIME()
);
GO

CREATE INDEX IX_stg_Person_BusinessEntityID ON stg.Person (BusinessEntityID);
GO
