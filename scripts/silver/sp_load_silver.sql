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

CREATE OR REPLACE PROCEDURE DATA_WAREHOUSE.BRONZE.SP_LOAD_BRONZE()
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
    v_log_msg := v_log_msg || 'BRONZE LOAD STARTED: ' || v_start_time::STRING || '\n';
    v_log_msg := v_log_msg || '==========================================================\n';

    -- 1. Load CRM Data (source_crm)
    
    -- Load CRM Customers
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.CRM_CUST_INFO;
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
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.CRM_PRD_INFO;
    
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'crm_prd_info      | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load CRM Sales Details
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.CRM_SALES_DETAILS;
    COPY INTO DATA_WAREHOUSE.BRONZE.CRM_SALES_DETAILS FROM (
        SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, CURRENT_TIMESTAMP() 
        FROM @DATA_WAREHOUSE.BRONZE.BRONZE_STAGE/source_crm/sales_details.csv
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'crm_sales_details | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- 2. Load ERP Data (source_erp)

    -- Load ERP Customers
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.ERP_CUST_AZ12;
    COPY INTO DATA_WAREHOUSE.BRONZE.ERP_CUST_AZ12 FROM (
        SELECT $1, $2, $3, CURRENT_TIMESTAMP() 
        FROM @DATA_WAREHOUSE.BRONZE.BRONZE_STAGE/source_erp/CUST_AZ12.csv
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'erp_cust_az12     | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load ERP Locations
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.ERP_LOC_A101;
    COPY INTO DATA_WAREHOUSE.BRONZE.ERP_LOC_A101 FROM (
        SELECT $1, $2, CURRENT_TIMESTAMP() 
        FROM @DATA_WAREHOUSE.BRONZE.BRONZE_STAGE/source_erp/LOC_A101.csv
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'erp_loc_a101      | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load ERP Product Categories
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.ERP_PX_CAT_G1V2;
    COPY INTO DATA_WAREHOUSE.BRONZE.ERP_PX_CAT_G1V2 FROM (
        SELECT $1, $2, $3, $4, CURRENT_TIMESTAMP() 
        FROM @DATA_WAREHOUSE.BRONZE.BRONZE_STAGE/source_erp/PX_CAT_G1V2.csv
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

