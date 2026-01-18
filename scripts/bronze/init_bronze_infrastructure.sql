/*
==============================================================================
BRONZE INFRASTRUCTURE SETUP
Description: Creates the Storage Integration for S3. 
Note: This should be run ONCE manually to maintain a stable AWS External ID.
==============================================================================
*/

USE ROLE ACCOUNTADMIN;

CREATE STORAGE INTEGRATION IF NOT EXISTS s3_bronze_int
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::708738536759:role/snowflake-s3-medallion-role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-sql-medallion-warehouse/bronze/');

-- Run this to get the External ID for AWS Trust Relationship
DESC STORAGE INTEGRATION s3_bronze_int;

-- Setup Stage (Ensures definition is correct without breaking streams)
CREATE STAGE IF NOT EXISTS DATA_WAREHOUSE.BRONZE.BRONZE_STAGE
    URL = 's3://snowflake-sql-medallion-warehouse/bronze/'
    STORAGE_INTEGRATION = s3_bronze_int
    DIRECTORY = (ENABLE = TRUE)
    FILE_FORMAT = (
        TYPE = CSV 
        FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
        SKIP_HEADER = 1
    );

-- Use ALTER for updates to avoid dropping the stage and breaking streams
ALTER STAGE DATA_WAREHOUSE.BRONZE.BRONZE_STAGE SET 
    STORAGE_INTEGRATION = s3_bronze_int,
    DIRECTORY = (ENABLE = TRUE);