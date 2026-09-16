-- =========================================================
-- BRONZE LAYER LOADING SCRIPT
-- =========================================================
-- Purpose:
-- Load raw CSV source files into Bronze layer tables
-- using bulk ingestion via LOAD DATA LOCAL INFILE in MySQL.
--
-- Notes:
-- 1. This script preserves raw source data.
-- 2. Tables are truncated before loading.
-- 3. LOAD DATA LOCAL INFILE is used for fast bulk loading.
-- 4. Row counts are displayed after loading for validation.
-- =========================================================


-- =========================================================
-- ENABLE LOCAL FILE LOADING
-- =========================================================

SET GLOBAL local_infile = 1;


-- =========================================================
-- USE BRONZE SCHEMA
-- =========================================================

USE bronze;


-- =========================================================
-- LOAD CRM TABLES
-- =========================================================

SELECT NOW() AS crm_load_start_time;


-- =========================================================
-- crm_cust_info
-- =========================================================

TRUNCATE TABLE bronze.crm_cust_info;

LOAD DATA LOCAL INFILE 
'C:/Users/Dell/Downloads/dbc9660c89a3480fa5eb9bae464d6c07/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    'bronze.crm_cust_info' AS table_name,
    COUNT(*) AS total_rows
FROM bronze.crm_cust_info;


-- =========================================================
-- crm_prd_info
-- =========================================================

TRUNCATE TABLE bronze.crm_prd_info;

LOAD DATA LOCAL INFILE 
'C:/Users/Dell/Downloads/dbc9660c89a3480fa5eb9bae464d6c07/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    'bronze.crm_prd_info' AS table_name,
    COUNT(*) AS total_rows
FROM bronze.crm_prd_info;


-- =========================================================
-- crm_sales_details
-- =========================================================

TRUNCATE TABLE bronze.crm_sales_details;

LOAD DATA LOCAL INFILE 
'C:/Users/Dell/Downloads/dbc9660c89a3480fa5eb9bae464d6c07/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    'bronze.crm_sales_details' AS table_name,
    COUNT(*) AS total_rows
FROM bronze.crm_sales_details;


SELECT NOW() AS crm_load_end_time;


-- =========================================================
-- LOAD ERP TABLES
-- =========================================================

SELECT NOW() AS erp_load_start_time;


-- =========================================================
-- erp_loc_a101
-- =========================================================

TRUNCATE TABLE bronze.erp_loc_a101;

LOAD DATA LOCAL INFILE 
'C:/Users/Dell/Downloads/dbc9660c89a3480fa5eb9bae464d6c07/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    'bronze.erp_loc_a101' AS table_name,
    COUNT(*) AS total_rows
FROM bronze.erp_loc_a101;


-- =========================================================
-- erp_cust_az12
-- =========================================================

TRUNCATE TABLE bronze.erp_cust_az12;

LOAD DATA LOCAL INFILE 
'C:/Users/Dell/Downloads/dbc9660c89a3480fa5eb9bae464d6c07/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    'bronze.erp_cust_az12' AS table_name,
    COUNT(*) AS total_rows
FROM bronze.erp_cust_az12;


-- =========================================================
-- erp_px_cat_g1v2
-- =========================================================

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

LOAD DATA LOCAL INFILE 
'C:/Users/Dell/Downloads/dbc9660c89a3480fa5eb9bae464d6c07/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    'bronze.erp_px_cat_g1v2' AS table_name,
    COUNT(*) AS total_rows
FROM bronze.erp_px_cat_g1v2;


SELECT NOW() AS erp_load_end_time;


-- =========================================================
-- FINAL VALIDATION
-- =========================================================

SELECT 'Bronze Layer Loading Completed Successfully' AS status;

describe bronze.crm_cust_info;
describe bronze.crm_prd_info;
 describe bronze.crm_sales_details;
 describe bronze.erp_loc_a101;
 describe bronze.erp_cust_az12;
describe bronze.erp_px_cat_g1v2;

select count(*) from bronze.crm_cust_info;
select count(*) from bronze.crm_prd_info;
select count(*) from bronze.crm_sales_details;
select count(*) from bronze.erp_loc_a101;
select count(*) from bronze.erp_cust_az12;
select count(*) from bronze.erp_px_cat_g1v2;

select * from bronze.erp_px_cat_g1v2;