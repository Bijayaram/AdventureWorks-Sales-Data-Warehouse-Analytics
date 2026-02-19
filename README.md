# AdventureWorks Data Warehouse (SQL Server)

## 📌 Overview

This project implements a production-style data warehouse using
**AdventureWorks2025** as the OLTP source and a separate database
(**AdventureWorksDW_Portfolio**) as the analytics warehouse.

The solution demonstrates:

-   Layered data architecture (staging → warehouse)
-   ETL execution logging
-   Identity handling and XML ingestion issues
-   Dimensional modeling (star schema)
-   Slowly Changing Dimension (SCD Type 2)
-   Fully validated fact table load

This project simulates real-world data engineering practices using SQL
Server.

------------------------------------------------------------------------

## 🏗 Architecture

AdventureWorks2025 (OLTP) ↓ AdventureWorksDW_Portfolio ├── stg (Raw
staging layer) ├── etl (ETL control & logging) └── dw (Dimensional star
schema)

------------------------------------------------------------------------

## 📂 Project Structure

AdventureWorksDW_Portfolio/ │ ├── sql/ │ ├── 01_create_schemas.sql │ ├──
02_create_etl_control_tables.sql │ ├── 03_create_staging_tables.sql │
├── 04_etl_load_staging.sql │ ├── 05_fix_staging_remove_identity.sql │
├── 07_dw_dim_date.sql │ ├── 08_dw_dim_product.sql │ ├──
09_dw_dim_sales_territory.sql │ ├── 10_dw_dim_customer_scd2.sql │ ├──
11_etl_load_dim_customer_scd2.sql │ └── 12_dw_fact_internet_sales.sql │
└── README.md

------------------------------------------------------------------------

## 🔹 Layer Design

### 1️⃣ Staging Layer (`stg`)

-   Raw copy of source tables
-   Preserves business keys
-   Removes identity properties
-   Handles typed XML limitations
-   Adds ETL audit columns (`ETL_RunID`, `ETL_LoadedAt`)

### 2️⃣ ETL Control Layer (`etl`)

-   `RunLog` tracks execution status, errors, and row counts
-   Stored procedures use TRY/CATCH blocks
-   Supports repeatable and traceable loads

### 3️⃣ Warehouse Layer (`dw`)

#### Dimensions

-   DimDate
-   DimProduct
-   DimSalesTerritory
-   DimCustomer (SCD Type 2)

#### Fact Table

-   FactInternetSales
-   Grain: SalesOrderID + SalesOrderDetailID
-   Fully resolved surrogate keys
-   Referential integrity validated

------------------------------------------------------------------------

## ⭐ Key Technical Highlights

### Identity Handling

`SELECT INTO` copied identity properties from source tables.\
Staging tables were rebuilt without identity columns to allow controlled
inserts.

### Typed XML Resolution

Source tables contained typed XML columns referencing schema
collections.\
These were excluded from staging because cross-database typed XML
references are not allowed.

### SCD Type 2 Implementation

DimCustomer tracks historical changes using: - StartDate - EndDate -
IsCurrent - RowHash for change detection

### Validation Results

-   Fact row count: 121,317
-   Missing Product Keys: 0
-   Missing Customer Keys: 0

------------------------------------------------------------------------

## 🚀 How to Run

1.  Execute scripts in order (01 → 12)
2.  Load staging: EXEC etl.usp_LoadStaging_InternetSales;
3.  Load Customer SCD2: EXEC etl.usp_LoadDimCustomer_SCD2;
4.  Load Fact table (12_dw_fact_internet_sales.sql)

------------------------------------------------------------------------

## 🧠 Skills Demonstrated

-   SQL Server development
-   Data warehouse architecture
-   Dimensional modeling (Kimball methodology)
-   SCD Type 2 logic
-   ETL error handling
-   Surrogate key design
-   Data validation and reconciliation

------------------------------------------------------------------------

## 🎯 Future Enhancements

-   Incremental fact loading (watermark-based)
-   Data quality validation framework
-   Power BI reporting layer
-   Automated scheduling

------------------------------------------------------------------------

Built as a production-style data engineering portfolio project.
