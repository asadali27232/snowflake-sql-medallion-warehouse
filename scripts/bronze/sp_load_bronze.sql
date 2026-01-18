USE ROLE ACCOUNTADMIN;
USE DATABASE DATA_WAREHOUSE;
USE SCHEMA BRONZE;

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

    -- 1. Sync Stage Metadata with S3 (to detect new/replaced files)
    -- Moving this here makes orchestration simpler and more reliable.
    ALTER STAGE DATA_WAREHOUSE.BRONZE.BRONZE_STAGE REFRESH;

    -- 2. Setup Stage (Ensures definition is correct)
    CREATE OR REPLACE STAGE DATA_WAREHOUSE.BRONZE.BRONZE_STAGE
        URL = 's3://snowflake-sql-medallion-warehouse/bronze/'
        STORAGE_INTEGRATION = s3_bronze_int
        FILE_FORMAT = (
            TYPE = CSV 
            FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
            SKIP_HEADER = 1
        );

    -- 3. Load CRM Data (source_crm)
    
    -- Load CRM Customers
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.CRM_CUST_INFO;
    COPY INTO DATA_WAREHOUSE.BRONZE.CRM_CUST_INFO FROM (
        SELECT $1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP() 
        FROM @DATA_WAREHOUSE.BRONZE.BRONZE_STAGE/source_crm/cust_info.csv
    );
    v_duration_sec := DATEDIFF(SECOND, v_step_start_time, CURRENT_TIMESTAMP());
    v_log_msg := v_log_msg || 'crm_cust_info     | Ingested in: ' || v_duration_sec::STRING || ' sec\n';

    -- Load CRM Products
    v_step_start_time := CURRENT_TIMESTAMP();
    TRUNCATE TABLE DATA_WAREHOUSE.BRONZE.CRM_PRD_INFO;
    COPY INTO DATA_WAREHOUSE.BRONZE.CRM_PRD_INFO FROM (
        SELECT $1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP() 
        FROM @DATA_WAREHOUSE.BRONZE.BRONZE_STAGE/source_crm/prd_info.csv
    );
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

    -- 4. Load ERP Data (source_erp)

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