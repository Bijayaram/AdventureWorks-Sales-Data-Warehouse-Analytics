USE AdventureWorksDW_Portfolio;
GO

DECLARE @MinDate DATE, @MaxDate DATE;

SELECT
    @MinDate = MIN(CAST(OrderDate AS DATE)),
    @MaxDate = MAX(CAST(OrderDate AS DATE))
FROM stg.SalesOrderHeader;

-- Add buffer (1 year before/after) to support reporting
SET @MinDate = DATEADD(YEAR, -1, @MinDate);
SET @MaxDate = DATEADD(YEAR,  1, @MaxDate);

;WITH n AS
(
    -- Generates a sequence of numbers (0..N)
    SELECT TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS num
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
d AS
(
    SELECT DATEADD(DAY, num, @MinDate) AS [Date]
    FROM n
)
INSERT INTO dw.DimDate
(
    DateKey, [Date], [Year], Quarter, MonthNumber, MonthName, MonthShortName,
    YearMonth, DayOfMonth, DayOfWeek, DayName, WeekOfYear, IsWeekend
)
SELECT
    CONVERT(INT, FORMAT([Date], 'yyyyMMdd')) AS DateKey,
    [Date],
    YEAR([Date]) AS [Year],
    DATEPART(QUARTER, [Date]) AS Quarter,
    MONTH([Date]) AS MonthNumber,
    DATENAME(MONTH, [Date]) AS MonthName,
    LEFT(DATENAME(MONTH, [Date]), 3) AS MonthShortName,
    CONVERT(CHAR(7), [Date], 126) AS YearMonth,  -- YYYY-MM
    DAY([Date]) AS DayOfMonth,
    DATEPART(WEEKDAY, [Date]) AS DayOfWeek,
    DATENAME(WEEKDAY, [Date]) AS DayName,
    DATEPART(WEEK, [Date]) AS WeekOfYear,
    CASE WHEN DATENAME(WEEKDAY, [Date]) IN ('Saturday','Sunday') THEN 1 ELSE 0 END AS IsWeekend
FROM d;
GO
