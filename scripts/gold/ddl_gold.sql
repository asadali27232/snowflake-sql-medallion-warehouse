/*
GOLD LAYER DDL:
  Create Gold views to store final dimension and fact tables.

WARNING:
  'CREATE OR REPLACE' will drop all existing views.

REQUIREMENTS:
  ROLE: ACCOUNTADMIN, WH: COMPUTE_WH, DB: DATA_WAREHOUSE, SCHEMA: GOLD
*/

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATA_WAREHOUSE;
USE SCHEMA GOLD;

-- =============================================================================
-- CREATE DIMENSION: GOLD.DIM_CUSTOMERS
-- =============================================================================
CREATE OR REPLACE VIEW DATA_WAREHOUSE.GOLD.DIM_CUSTOMERS AS
SELECT
    ROW_NUMBER() OVER (ORDER BY CI.CST_ID) AS CUSTOMER_KEY, -- Surrogate key
    CI.CST_ID                             AS CUSTOMER_ID,
    CI.CST_KEY                            AS CUSTOMER_NUMBER,
    CI.CST_FIRSTNAME                      AS FIRST_NAME,
    CI.CST_LASTNAME                       AS LAST_NAME,
    LA.CNTRY                              AS COUNTRY,
    CI.CST_MARITAL_STATUS                 AS MARITAL_STATUS,
    CASE 
        WHEN CI.CST_GNDR != 'N/A' THEN CI.CST_GNDR -- CRM is the primary source for gender
        ELSE COALESCE(CA.GEN, 'UNKNOWN')           -- Fallback to ERP data
    END                                   AS GENDER,
    CA.BDATE                              AS BIRTHDATE,
    CI.CST_CREATE_DATE                    AS CREATE_DATE
FROM DATA_WAREHOUSE.SILVER.CRM_CUST_INFO CI
LEFT JOIN DATA_WAREHOUSE.SILVER.ERP_CUST_AZ12 CA
    ON CI.CST_KEY = CA.CID
LEFT JOIN DATA_WAREHOUSE.SILVER.ERP_LOC_A101 LA
    ON CI.CST_KEY = LA.CID;

-- =============================================================================
-- CREATE DIMENSION: GOLD.DIM_PRODUCTS
-- =============================================================================
CREATE OR REPLACE VIEW DATA_WAREHOUSE.GOLD.DIM_PRODUCTS AS
SELECT
    ROW_NUMBER() OVER (ORDER BY PN.PRD_START_DT, PN.PRD_KEY) AS PRODUCT_KEY, -- Surrogate key
    PN.PRD_ID       AS PRODUCT_ID,
    PN.PRD_KEY      AS PRODUCT_NUMBER,
    PN.PRD_NM       AS PRODUCT_NAME,
    PN.CAT_ID       AS CATEGORY_ID,
    PC.CAT          AS CATEGORY,
    PC.SUBCAT       AS SUBCATEGORY,
    PC.MAINTENANCE  AS MAINTENANCE,
    PN.PRD_COST     AS COST,
    PN.PRD_LINE     AS PRODUCT_LINE,
    PN.PRD_START_DT AS START_DATE
FROM DATA_WAREHOUSE.SILVER.CRM_PRD_INFO PN
LEFT JOIN DATA_WAREHOUSE.SILVER.ERP_PX_CAT_G1V2 PC
    ON PN.CAT_ID = PC.ID
WHERE PN.PRD_END_DT IS NULL; -- Filter out all historical data

-- =============================================================================
-- CREATE FACT TABLE: GOLD.FACT_SALES
-- =============================================================================
CREATE OR REPLACE VIEW DATA_WAREHOUSE.GOLD.FACT_SALES AS
SELECT
    SD.SLS_ORD_NUM  AS ORDER_NUMBER,
    PR.PRODUCT_KEY  AS PRODUCT_KEY,
    CU.CUSTOMER_KEY AS CUSTOMER_KEY,
    SD.SLS_ORDER_DT AS ORDER_DATE,
    SD.SLS_SHIP_DT  AS SHIPPING_DATE,
    SD.SLS_DUE_DT   AS DUE_DATE,
    SD.SLS_SALES    AS SALES_AMOUNT,
    SD.SLS_QUANTITY AS QUANTITY,
    SD.SLS_PRICE    AS PRICE
FROM DATA_WAREHOUSE.SILVER.CRM_SALES_DETAILS SD
LEFT JOIN DATA_WAREHOUSE.GOLD.DIM_PRODUCTS PR
    ON SD.SLS_PRD_KEY = PR.PRODUCT_NUMBER
LEFT JOIN DATA_WAREHOUSE.GOLD.DIM_CUSTOMERS CU
    ON SD.SLS_CUST_ID = CU.CUSTOMER_ID;
