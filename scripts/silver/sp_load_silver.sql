/*
SILVER LAYER STORED PROCEDURE:
  Load cleaned data from Bronze tables to Silver tables.
  
WARNING:
  This procedure will TRUNCATE existing tables before loading.

REQUIREMENTS:
  ROLE: ACCOUNTADMIN, WH: COMPUTE_WH, DB: DATA_WAREHOUSE, SCHEMA: SILVER
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATA_WAREHOUSE;
USE SCHEMA SILVER;

CREATE OR REPLACE PROCEDURE DATA_WAREHOUSE.SILVER.SP_LOAD_SILVER()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    v_start_time      TIMESTAMP_NTZ;
    v_step_start_time TIMESTAMP_NTZ;
    v_end_time        TIMESTAMP_NTZ;
    v_duration_sec    INT;
    v_log_msg         STRING DEFAULT '';
BEGIN
    v_start_time := CURRENT_TIMESTAMP();
    v_log_msg := v_log_msg || '==========================================================\n';
    v_log_msg := v_log_msg || 'SILVER LOAD STARTED: ' || v_start_time::STRING || '\n';
    v_log_msg := v_log_msg || '==========================================================\n';

    -- 1. Load CRM Data (source_crm)
    
    -- Load CRM Customers
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.SILVER.CRM_CUST_INFO;
    INSERT INTO DATA_WAREHOUSE.SILVER.CRM_CUST_INFO
    (
        SELECT
            CST_ID,
            CST_KEY,
            CST_FIRSTNAME,
            CST_LASTNAME,
            CST_MARITAL_STATUS,
            CST_GNDR,
            CST_CREATE_DATE,
            EXTRACTION_TIME,
            CURRENT_TIMESTAMP() AS dwh_create_date
        FROM (
            SELECT
                CST_ID,
                CST_KEY,
                TRIM(CST_FIRSTNAME) AS CST_FIRSTNAME,
                TRIM(CST_LASTNAME) AS CST_LASTNAME,
                CASE
                    WHEN UPPER(CST_MARITAL_STATUS) = 'S' THEN 'SINGLE'
                    WHEN UPPER(CST_MARITAL_STATUS) = 'M' THEN 'MARRIED'
                    ELSE 'UNKNOWN'
                END AS CST_MARITAL_STATUS,
                CASE
                    WHEN UPPER(CST_GNDR) = 'M' THEN 'MALE'
                    WHEN UPPER(CST_GNDR) = 'F' THEN 'FEMALE'
                    ELSE 'UNKNOWN'
                END AS CST_GNDR,
                CST_CREATE_DATE,
                EXTRACTION_TIME,
                ROW_NUMBER() OVER (PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) AS ROW_RANK
            FROM
                DATA_WAREHOUSE.BRONZE.CRM_CUST_INFO
        ) AS t
        WHERE ROW_RANK = 1
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'crm_cust_info     | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load CRM Products
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.SILVER.CRM_PRD_INFO;
    INSERT INTO DATA_WAREHOUSE.SILVER.CRM_PRD_INFO
    (
        SELECT
            PRD_ID,
            SUBSTRING(PRD_KEY, 7, LENGTH(PRD_KEY)) AS PRD_KEY,
            REPLACE(SUBSTRING(PRD_KEY, 1, 5), '-', '_') AS  CAT_ID,
            TRIM(PRD_NM) AS PRD_NM,
            COALESCE(PRD_COST, 0) AS PRD_COST,
            CASE UPPER(TRIM(PRD_LINE))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'UNKNOWN'
            END AS PRD_LINE,
            CAST(PRD_START_DT AS DATE) AS PRD_START_DT,
            CAST(
                DATEADD(
                day,
                -1,
                LEAD(PRD_START_DT) OVER (
                    PARTITION BY PRD_KEY
                    ORDER BY PRD_START_DT
                )
                ) AS DATE
            ) AS PRD_END_DT,
            EXTRACTION_TIME,
            CURRENT_TIMESTAMP() AS dwh_create_date
        FROM
            DATA_WAREHOUSE.BRONZE.CRM_PRD_INFO
    );

    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'crm_prd_info      | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load CRM Sales Details
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.SILVER.CRM_SALES_DETAILS;
    INSERT INTO DATA_WAREHOUSE.SILVER.CRM_SALES_DETAILS
    (
        SELECT
            SLS_ORD_NUM,
            SLS_PRD_KEY,
            SLS_CUST_ID,
            CASE
                WHEN SLS_ORDER_DT <= 0 OR LENGTH(SLS_ORDER_DT) != 8 THEN NULL
                ELSE CAST(CAST(SLS_ORDER_DT AS VARCHAR) AS DATE)
            END AS SLS_ORDER_DT,
            CASE
                WHEN SLS_SHIP_DT <= 0 OR LENGTH(SLS_SHIP_DT) != 8 THEN NULL
                ELSE CAST(CAST(SLS_SHIP_DT AS VARCHAR) AS DATE)
            END AS SLS_SHIP_DT,
            CASE
                WHEN SLS_DUE_DT <= 0 OR LENGTH(SLS_DUE_DT) != 8 THEN NULL
                ELSE CAST(CAST(SLS_DUE_DT AS VARCHAR) AS DATE)
            END AS SLS_DUE_DT,
            CASE
                WHEN SLS_SALES != SLS_QUANTITY * ABS(SLS_PRICE) OR SLS_SALES IS NULL OR SLS_SALES <=0
                    THEN ABS(SLS_QUANTITY) * ABS(SLS_PRICE)
                ELSE ABS(SLS_SALES)
            END AS SLS_SALES,
            SLS_QUANTITY,
            CAST(
                CASE
                    WHEN SLS_PRICE IS NULL OR SLS_PRICE <=0 THEN  SLS_SALES / NULLIF(SLS_QUANTITY, 0)
                    ELSE ABS(SLS_PRICE)
                END AS INT) AS SLS_PRICE,   
            EXTRACTION_TIME,
            CURRENT_TIMESTAMP() AS dwh_create_date
        FROM
            DATA_WAREHOUSE.BRONZE.CRM_SALES_DETAILS
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'crm_sales_details | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- 2. Load ERP Data (source_erp)

    -- Load ERP Customers
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.SILVER.ERP_CUST_AZ12;
    INSERT INTO DATA_WAREHOUSE.SILVER.ERP_CUST_AZ12
    (
        SELECT
            CASE
                WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LENGTH(CID))
            END AS CID,
            CASE
                WHEN BDATE < '1924-01-01' OR BDATE > CURRENT_DATE() THEN NULL
                ELSE BDATE
            END AS BDATE,
            CASE
                WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'UNKNOWN'
            END AS GEN,
            EXTRACTION_TIME,
            CURRENT_TIMESTAMP() as dwh_create_date
        FROM
            DATA_WAREHOUSE.BRONZE.ERP_CUST_AZ12
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'erp_cust_az12     | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load ERP Locations
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.SILVER.ERP_LOC_A101;
    INSERT INTO DATA_WAREHOUSE.SILVER.ERP_LOC_A101 
    (
        SELECT
            REPLACE(CID, '-', '') AS CID,
            CASE
                WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
                WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'UNKNOWN'
                ELSE TRIM(CNTRY)
            END AS CNTRY,
            EXTRACTION_TIME,
            CURRENT_TIMESTAMP as dwh_create_date
        FROM
            DATA_WAREHOUSE.BRONZE.ERP_LOC_A101
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'erp_loc_a101      | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load ERP Product Categories
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.SILVER.ERP_PX_CAT_G1V2;
    INSERT INTO DATA_WAREHOUSE.SILVER.ERP_PX_CAT_G1V2
    (
        SELECT
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        FROM DATA_WAREHOUSE.BRONZE.ERP_PX_CAT_G1V2
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'erp_px_cat_g1v2   | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    v_end_time := CURRENT_TIMESTAMP();
    v_log_msg := v_log_msg || '==========================================================\n';
    v_log_msg := v_log_msg || 'TOTAL DURATION: ' || DATEDIFF(SECOND, v_start_time, v_end_time) || ' seconds\n';
    v_log_msg := v_log_msg || '==========================================================\n';

    RETURN v_log_msg;

EXCEPTION
    WHEN OTHER THEN
        RETURN 'ERROR ENCOUNTERED: ' || SQLERRM;
END;
$$;