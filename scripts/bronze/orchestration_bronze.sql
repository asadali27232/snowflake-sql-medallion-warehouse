/*
==============================================================================
BRONZE ORCHESTRATION
Description: Sets up automated triggering for the Bronze Load process.
Mechanism: Uses a Task to execute the Stored Procedure on a schedule.
           The SP now handles the S3 refresh logic internally.
==============================================================================
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATA_WAREHOUSE;
USE SCHEMA BRONZE;

-- 1. Ensure Directory Table is enabled
ALTER STAGE DATA_WAREHOUSE.BRONZE.BRONZE_STAGE SET DIRECTORY = (ENABLE = TRUE);

-- 2. Create a Task to Run the Stored Procedure
-- This remains a single statement to ensure compatibility with all CLIs.
-- It runs every minute, refreshes S3, and loads if data is found.
CREATE OR REPLACE TASK DATA_WAREHOUSE.BRONZE.TSK_LOAD_BRONZE
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
AS
    CALL DATA_WAREHOUSE.BRONZE.SP_LOAD_BRONZE();

-- 3. Resume the Task
ALTER TASK DATA_WAREHOUSE.BRONZE.TSK_LOAD_BRONZE RESUME;
