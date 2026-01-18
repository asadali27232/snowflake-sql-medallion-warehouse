USE ROLE ACCOUNTADMIN;
USE DATABASE DATA_WAREHOUSE;
USE SCHEMA BRONZE;

CREATE OR REPLACE PROCEDURE data_warehouse.bronze.sp_load_bronze()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Create a file format
    CREATE OR REPLACE FILE FORMAT file_format
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1;
    
    -- Create a stage
    CREATE OR REPLACE STAGE bronze_stage
    URL = 's3://snowflake-sql-medallion-warehouse/bronze'
    CREDENTIALS = (AWS_ROLE = 'arn:aws:iam::011868794051:user/8eoc1000-s');
    
    RETURN 'Bronze layer loaded successfully';
END;
$$;