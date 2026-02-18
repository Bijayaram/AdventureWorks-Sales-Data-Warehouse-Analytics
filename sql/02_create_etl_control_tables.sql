/* =========================================================
   File: sql/02_create_etl_control_tables.sql
   Database: AdventureWorksDW_Portfolio
   Purpose:
     - etl.RunLog     : log each ETL pipeline execution
     - etl.Watermark  : store last successful load timestamp per entity
     - etl.DataQualityResults : store DQ check results
========================================================= */

USE AdventureWorksDW_Portfolio;
GO

/* =========================================================
   1) etl.RunLog
   ---------------------------------------------------------
   This table answers:
     - When did the pipeline run?
     - Did it succeed or fail?
     - How many rows were inserted/updated?
     - What was the error message (if any)?
========================================================= */

IF OBJECT_ID('etl.RunLog', 'U') IS NULL
BEGIN
    CREATE TABLE etl.RunLog
    (
        RunID            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PipelineName     SYSNAME           NOT NULL, -- e.g., 'Load_InternetSales'
        StartTime        DATETIME2(0)       NOT NULL CONSTRAINT DF_RunLog_Start DEFAULT SYSUTCDATETIME(),
        EndTime          DATETIME2(0)       NULL,
        Status           VARCHAR(20)        NOT NULL CONSTRAINT DF_RunLog_Status DEFAULT ('Started'),
        -- Typical values: Started, Success, Failed

        RowsInserted     INT               NULL CONSTRAINT DF_RunLog_RowsInserted DEFAULT (0),
        RowsUpdated      INT               NULL CONSTRAINT DF_RunLog_RowsUpdated  DEFAULT (0),
        RowsDeleted      INT               NULL CONSTRAINT DF_RunLog_RowsDeleted  DEFAULT (0),

        ErrorNumber      INT               NULL,
        ErrorMessage     NVARCHAR(4000)     NULL
    );

    CREATE INDEX IX_RunLog_Pipeline_StartTime
        ON etl.RunLog (PipelineName, StartTime DESC);

    PRINT 'Created etl.RunLog';
END
ELSE
BEGIN
    PRINT 'etl.RunLog already exists';
END;
GO


/* =========================================================
   2) etl.Watermark
     
========================================================= */

IF OBJECT_ID('etl.Watermark', 'U') IS NULL
BEGIN
    CREATE TABLE etl.Watermark
    (
        EntityName        SYSNAME       NOT NULL PRIMARY KEY, -- e.g., 'FactInternetSales'
        LastSuccessValue  DATETIME2(0)   NOT NULL,            -- e.g., last max ModifiedDate loaded
        UpdatedAt         DATETIME2(0)   NOT NULL CONSTRAINT DF_Watermark_UpdatedAt DEFAULT SYSUTCDATETIME()
    );

    PRINT 'Created etl.Watermark';
END
ELSE
BEGIN
    PRINT 'etl.Watermark already exists';
END;
GO


/* =========================================================
   Seed initial watermark values (so first incremental run works)
   ---------------------------------------------------------
========================================================= */

IF NOT EXISTS (SELECT 1 FROM etl.Watermark WHERE EntityName = 'FactInternetSales')
BEGIN
    INSERT INTO etl.Watermark (EntityName, LastSuccessValue)
    VALUES ('FactInternetSales', '1900-01-01');

    PRINT 'Seeded watermark for FactInternetSales';
END
ELSE
BEGIN
    PRINT 'Watermark for FactInternetSales already seeded';
END;
GO


/* =========================================================
   3) etl.DataQualityResults
   ---------------------------------------------------------
========================================================= */

IF OBJECT_ID('etl.DataQualityResults', 'U') IS NULL
BEGIN
    CREATE TABLE etl.DataQualityResults
    (
        DQResultID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        RunID          INT               NOT NULL,
        CheckName      VARCHAR(200)      NOT NULL,
        Status         VARCHAR(20)       NOT NULL, -- Pass/Fail
        BadRowCount    INT               NOT NULL CONSTRAINT DF_DQ_BadRowCount DEFAULT (0),
        Notes          NVARCHAR(2000)    NULL,
        CheckedAt      DATETIME2(0)      NOT NULL CONSTRAINT DF_DQ_CheckedAt DEFAULT SYSUTCDATETIME(),

        CONSTRAINT FK_DQ_RunLog
            FOREIGN KEY (RunID) REFERENCES etl.RunLog(RunID)
    );

    CREATE INDEX IX_DQ_RunID ON etl.DataQualityResults (RunID);

    PRINT 'Created etl.DataQualityResults';
END
ELSE
BEGIN
    PRINT 'etl.DataQualityResults already exists';
END;
GO


/* =========================================================
   Verify
========================================================= */
SELECT TOP 10 * FROM etl.RunLog ORDER BY RunID DESC;
SELECT * FROM etl.Watermark ORDER BY EntityName;
GO
