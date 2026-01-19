
/*
SILVER LAYER DDL:
  Create Silver tables to store cleaned data.

WARNING:
  'CREATE OR REPLACE' will drop all existing data in the tables.

REQUIREMENTS:
  ROLE: ACCOUNTADMIN, WH: COMPUTE_WH, DB: DATA_WAREHOUSE, SCHEMA: SILVER
*/

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATA_WAREHOUSE;
USE SCHEMA SILVER;

CREATE OR REPLACE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             STRING,
    cst_firstname       STRING,
    cst_lastname        STRING,
    cst_marital_status  STRING,
    cst_gndr            STRING,
    cst_create_date     DATE,
    extraction_time     TIMESTAMP_NTZ,
    dwh_create_date     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE silver.crm_prd_info (
    prd_id              INT,
    prd_key             STRING,
    cat_id              STRING,
    prd_nm              STRING,
    prd_cost            INT,
    prd_line            STRING,
    prd_start_dt        DATE,
    prd_end_dt          DATE,
    extraction_time     TIMESTAMP_NTZ,
    dwh_create_date     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE silver.crm_sales_details (
    sls_ord_num         STRING,
    sls_prd_key         STRING,
    sls_cust_id         INT,
    sls_order_dt        INT,
    sls_ship_dt         INT,
    sls_due_dt          INT,
    sls_sales           INT,
    sls_quantity        INT,
    sls_price           INT,
    extraction_time     TIMESTAMP_NTZ,
    dwh_create_date     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE silver.erp_loc_a101 (
    cid                 STRING,
    cntry               STRING,
    extraction_time     TIMESTAMP_NTZ,
    dwh_create_date     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE silver.erp_cust_az12 (
    cid                 STRING,
    bdate               DATE,
    gen                 STRING,
    extraction_time     TIMESTAMP_NTZ,
    dwh_create_date     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE silver.erp_px_cat_g1v2 (
    id                  STRING,
    cat                 STRING,
    subcat              STRING,
    maintenance         STRING,
    extraction_time     TIMESTAMP_NTZ,
    dwh_create_date     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);