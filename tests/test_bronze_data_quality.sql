-- Bronze Layer Data Quality Tests
-- Tests for raw data ingestion validation

-- Test 1: Check for null primary keys
-- SELECT 
--     COUNT(*) as null_pk_count
-- FROM bronze.your_table
-- WHERE primary_key_column IS NULL;

-- Test 2: Check for duplicate records
-- SELECT 
--     primary_key_column,
--     COUNT(*) as duplicate_count
-- FROM bronze.your_table
-- GROUP BY primary_key_column
-- HAVING COUNT(*) > 1;

-- Test 3: Validate data freshness
-- SELECT 
--     MAX(ingestion_timestamp) as last_ingestion,
--     DATEDIFF(hour, MAX(ingestion_timestamp), CURRENT_TIMESTAMP()) as hours_since_last_load
-- FROM bronze.your_table;

-- Test 4: Check row count
-- SELECT 
--     COUNT(*) as total_rows
-- FROM bronze.your_table;
