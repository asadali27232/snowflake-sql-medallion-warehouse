/*
SILVER LAYER ORCHESTRATION:
  Automate the Silver load by scheduling the stored procedure.
  This task transforms cleaned and formatted data from Bronze to Silver.

WARNING:
  Tasks must be RESUMED manually after modification or deployment.

REQUIREMENTS:
  ROLE: ACCOUNTADMIN, WH: COMPUTE_WH, DB: DATA_WAREHOUSE, SCHEMA: SILVER
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATA_WAREHOUSE;
USE SCHEMA SILVER;

-- Create a Task to Run the Silver Stored Procedure
-- This task runs on a schedule (e.g., every 5 minutes)
CREATE OR REPLACE TASK DATA_WAREHOUSE.SILVER.TSK_LOAD_SILVER
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '5 MINUTE'
AS
    CALL DATA_WAREHOUSE.SILVER.SP_LOAD_SILVER();

-- Resume the Task (Tasks are created in a SUSPENDED state)
ALTER TASK DATA_WAREHOUSE.SILVER.TSK_LOAD_SILVER RESUME;
