USE AdventureWorksDW_Portfolio;
GO

IF OBJECT_ID('dw.DimDate','U') IS NOT NULL
    DROP TABLE dw.DimDate;
GO

CREATE TABLE dw.DimDate
(
    DateKey        INT         NOT NULL PRIMARY KEY,   -- YYYYMMDD
    [Date]         DATE        NOT NULL,
    [Year]         SMALLINT    NOT NULL,
    Quarter        TINYINT     NOT NULL,
    MonthNumber    TINYINT     NOT NULL,
    MonthName      NVARCHAR(20) NOT NULL,
    MonthShortName NCHAR(3)    NOT NULL,
    YearMonth      CHAR(7)     NOT NULL,               -- YYYY-MM
    DayOfMonth     TINYINT     NOT NULL,
    DayOfWeek      TINYINT     NOT NULL,               -- 1-7 depends on DATEFIRST
    DayName        NVARCHAR(20) NOT NULL,
    WeekOfYear     TINYINT     NOT NULL,
    IsWeekend      BIT         NOT NULL
);
GO
