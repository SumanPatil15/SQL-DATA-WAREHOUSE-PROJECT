# MySQL Data Warehouse – Medallion Architecture

## Project Overview

Built a **MySQL Data Warehouse** using the **Medallion Architecture** to integrate and transform data from **CRM and ERP source systems** into a business-ready **Star Schema**.

### Data Sources

The project uses **6 source CSV files**:

**CRM**

* `crm_cust_info` – Customer information
* `crm_prd_info` – Product information
* `crm_sales_details` – Sales transactions

**ERP**

* `erp_cust_az12` – Customer demographic information
* `erp_loc_a101` – Customer location information
* `erp_px_cat_g1v2` – Product category information

---

## Architecture

```text
CRM & ERP CSV Files
        ↓
   Bronze Layer
     (Raw Data)
        ↓
   Data Profiling
        ↓
   Silver Layer
(Cleaned & Transformed)
        ↓
    Gold Layer
 (Business-Ready Data)
        ↓
    Star Schema
```

## Bronze Layer

* Created **6 staging tables** matching the source CSV structures.
* Loaded raw data using `LOAD DATA LOCAL INFILE`.
* Used a **full-refresh approach** by truncating tables before loading.
* Preserved source data without applying transformations or constraints.
* Performed row-count validation and load-time tracking.

## Data Profiling

Performed profiling on all Bronze tables to identify:

* Duplicate and NULL records
* Invalid dates and values
* Inconsistent gender, marital status, and country values
* Missing or negative product costs
* Referential integrity issues
* Invalid sales amounts and quantities
* Unwanted spaces and hidden characters

## Silver Layer

Created cleaned and transformed versions of all source tables.

Key transformations included:

* Deduplication using `ROW_NUMBER()`
* Product validity dates using `LEAD()`
* Data type and date conversions
* NULL and invalid value handling
* Standardization of gender, marital status, country, and product categories
* CRM and ERP data integration
* Customer and product data cleansing
* Business-rule validation

The transformation process was implemented through a **`load_silver` stored procedure**.

## Gold Layer

Created a **Star Schema** consisting of:

* `dim_customers`
* `dim_products`
* `fact_sales`

The dimension views combine and enrich data from CRM and ERP sources.

Surrogate keys were generated using `ROW_NUMBER()` and used to connect the fact table with the customer and product dimensions.

The `fact_sales` view contains measures such as:

* Sales Amount
* Quantity
* Price

Final referential-integrity checks were performed to ensure fact records correctly matched the dimension records.

## Technologies & Concepts

* **MySQL**
* **SQL**
* **Medallion Architecture**
* **Star Schema**
* **Dimensional Modeling**
* CTEs
* Window Functions
* Stored Procedures
* Data Cleaning & Validation
* Data Profiling
* ETL
