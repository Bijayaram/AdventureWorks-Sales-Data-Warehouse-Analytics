/* =========================================================
   File: sql/01_create_schemas.sql
   Purpose: Create schemas for a simple DW architecture
            stg = staging/landing
            dw  = dimensional warehouse (star schema)
            etl = logging, watermarks, controls
   Notes:
     - This script is idempotent (won't error if schemas exist).
========================================================= */

-- Optional: set the database context (change this to your DW database)
USE AdventureWorksDW_Portfolio;
GO


-- Create STAGING schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg AUTHORIZATION dbo;');
    PRINT 'Schema [stg] created.';
END
ELSE
    PRINT 'Schema [stg] already exists.';

-- Create DATA WAREHOUSE schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dw')
BEGIN
    EXEC('CREATE SCHEMA dw AUTHORIZATION dbo;');
    PRINT 'Schema [dw] created.';
END
ELSE
    PRINT 'Schema [dw] already exists.';

-- Create ETL/CONTROL schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl')
BEGIN
    EXEC('CREATE SCHEMA etl AUTHORIZATION dbo;');
    PRINT 'Schema [etl] created.';
END
ELSE
    PRINT 'Schema [etl] already exists.';
GO

-- Verify
SELECT name AS SchemaName
FROM sys.schemas
WHERE name IN ('stg','dw','etl')
ORDER BY name;
