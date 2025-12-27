-- Silver Layer Data Quality Tests
-- Tests for cleaned and transformed data validation

-- Test 1: Check for null values in required columns
-- SELECT 
--     COUNT(*) as null_required_fields
-- FROM silver.your_table
-- WHERE required_column IS NULL;

-- Test 2: Validate data types and formats
-- SELECT 
--     COUNT(*) as invalid_email_format
-- FROM silver.your_table
-- WHERE email_column NOT RLIKE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$';

-- Test 3: Check referential integrity
-- SELECT 
--     COUNT(*) as orphaned_records
-- FROM silver.child_table c
-- LEFT JOIN silver.parent_table p ON c.parent_id = p.id
-- WHERE p.id IS NULL;

-- Test 4: Validate business rules
-- SELECT 
--     COUNT(*) as invalid_amount
-- FROM silver.your_table
-- WHERE amount < 0;

-- Test 5: Check for duplicates after deduplication
-- SELECT 
--     business_key,
--     COUNT(*) as duplicate_count
-- FROM silver.your_table
-- GROUP BY business_key
-- HAVING COUNT(*) > 1;
