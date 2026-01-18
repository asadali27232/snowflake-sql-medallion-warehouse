/*
==============================================================================
BRONZE INFRASTRUCTURE SETUP
Description: Creates the Storage Integration for S3. 
Note: This should be run ONCE manually to maintain a stable AWS External ID.
==============================================================================
*/

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION s3_bronze_int
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::708738536759:role/snowflake-s3-medallion-role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-sql-medallion-warehouse/bronze/');

-- Run this to get the External ID for AWS Trust Relationship
DESC STORAGE INTEGRATION s3_bronze_int;
