-- Gold Layer Data Quality Tests
-- Tests for business-level aggregates and analytics validation

-- Test 1: Validate aggregate calculations
-- SELECT 
--     SUM(total_amount) as calculated_total,
--     (SELECT SUM(amount) FROM silver.source_table) as source_total,
--     ABS(SUM(total_amount) - (SELECT SUM(amount) FROM silver.source_table)) as variance
-- FROM gold.your_mart;

-- Test 2: Check for missing dimensions
-- SELECT 
--     COUNT(*) as records_with_null_dimensions
-- FROM gold.your_mart
-- WHERE dimension_column IS NULL;

-- Test 3: Validate time periods
-- SELECT 
--     date_column,
--     COUNT(*) as record_count
-- FROM gold.your_mart
-- GROUP BY date_column
-- ORDER BY date_column;

-- Test 4: Check metric consistency
-- SELECT 
--     metric_name,
--     metric_value,
--     CASE 
--         WHEN metric_value < 0 THEN 'Invalid: Negative Value'
--         WHEN metric_value IS NULL THEN 'Invalid: Null Value'
--         ELSE 'Valid'
--     END as validation_status
-- FROM gold.your_mart;

-- Test 5: Validate grain/uniqueness
-- SELECT 
--     date_key,
--     dimension_key,
--     COUNT(*) as duplicate_count
-- FROM gold.your_mart
-- GROUP BY date_key, dimension_key
-- HAVING COUNT(*) > 1;
