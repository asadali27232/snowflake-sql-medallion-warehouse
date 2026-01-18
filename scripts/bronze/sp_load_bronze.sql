
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
    CREDENTIALS = (AWS_ROLE = 'arn:aws:iam::123456789012:role/snowflake-sql-medallion-warehouse');
    
    -- Load data from S3 into a table
    COPY INTO bronze_table
    FROM @bronze_stage
    FILE_FORMAT = file_format;
    
    RETURN 'Bronze layer loaded successfully';
END;
$$;