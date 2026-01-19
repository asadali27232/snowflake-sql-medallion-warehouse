/*
GOLD LAYER ORCHESTRATION:
  Automate the Gold layer transformation by scheduling the SP_LOAD_GOLD procedure.
  This task ensures that reporting views are updated on a regular schedule.

WARNING:
  Tasks are created in a SUSPENDED state and must be manually resumed.

REQUIREMENTS:
  ROLE: ACCOUNTADMIN, WH: COMPUTE_WH, DB: DATA_WAREHOUSE, SCHEMA: GOLD
*/

USE ROLE ACCOUNTADMIN;
USE DATABASE DATA_WAREHOUSE;
USE SCHEMA GOLD;

-- Create a Task to Run the Gold Stored Procedure
-- This task is scheduled to run daily at midnight (UTC)
-- Note: The task will remain SUSPENDED as requested.
CREATE OR REPLACE TASK DATA_WAREHOUSE.GOLD.TSK_LOAD_GOLD
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 0 * * * UTC' -- Daily at midnight
AS
    CALL DATA_WAREHOUSE.GOLD.SP_LOAD_GOLD();
