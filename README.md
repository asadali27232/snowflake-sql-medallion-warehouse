# Snowflake SQL Medallion Warehouse: Modern Data Engineering in Snowflake

---

## Overview

This project implements a complete **Medallion Architecture** in **Snowflake**, transforming raw retail sales data into business-ready insights. Following the medallion pattern, data flows through three logical layers—**Bronze (Raw)**, **Silver (Refined)**, and **Gold (Curated)**—ensuring data quality, reliability, and performance for analytics.

The system utilizes **Snowflake's** powerful SQL engine to orchestrate the ETL/ELT process, converting normalized source data into a star schema optimized for business intelligence and reporting.

---

## Project Goals

1.  **Medallion Architecture Implementation**
    Logically organize data into Bronze, Silver, and Gold layers to incrementally improve data quality and structure.

2.  **Infrastructure as Code (IaC)**
    Provision Snowflake resources (databases, warehouses, roles, and schemas) using **Terraform** for reproducible deployments.

3.  **Data Quality and Validation**
    Implement rigorous data cleaning and validation in the Silver layer to ensure a "single source of truth."

4.  **Star Schema Modeling**
    Transform raw relational data into a denormalized star schema (Fact and Dimension tables) in the Gold layer for high-performance analytics.

5.  **SQL-Driven Orchestration**
    Use standard SQL for all data transformations, leveraging Snowflake's scalability and performance.

6.  **Business Intelligence Ready**
    Prepare curated data for consumption by BI tools and analytical dashboards.

---

## Tech Stack

| Technology                                                                                                                      | Purpose                                                           |
| :------------------------------------------------------------------------------------------------------------------------------ | :---------------------------------------------------------------- |
| ![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)                  | Cloud Data Warehouse for storage and high-performance processing. |
| ![SQL](https://img.shields.io/badge/SQL-CC2927?style=for-the-badge&logo=postgresql&logoColor=white)                             | Primary language for data transformation and modeling.            |
| ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)                  | Infrastructure as Code for Snowflake resource provisioning.       |
| ![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white) | CI/CD pipelines for automated deployments and testing.            |

---

## Architecture Diagram

![Architecture Diagram](images/architecture.png)

### Architecture Components

-   **Source Layer**: Raw data ingestion into Snowflake (CSV, JSON, or external stages).
-   **Bronze Layer (Raw)**: Landing zone that preserves the original data structure and lineage.
-   **Silver Layer (Refined)**: Cleaned, deduplicated, and validated data applying business rules.
-   **Gold Layer (Curated)**: Analytics-ready star schema with Fact and Dimension tables.
-   **Consumption Layer**: Serving layer for BI tools like Power BI, Tableau, or Jupyter Notebooks.

---

## Dataset

-   **Source**: [MySQL Sample Database - Classic Models](https://www.mysqltutorial.org/mysql-sample-database.aspx)
-   **Description**: A retailer database containing historical purchases and customer information across 8 tables:
    -   `customers`, `products`, `productlines`, `orders`, `orderdetails`, `payments`, `employees`, `offices`
-   **Use Case**: Analyze sales trends, product line performance, and geographic distribution of purchases.

### Data Transformation: Raw to Star Schema

**Before ETL (Normalized Source Schema):**

![Schema Before ETL](images/schema_before_etl.png)

**After ETL (Star Schema in Gold Layer):**

![Schema After ETL](images/schema_after_ETL.png)

The transformation creates:

-   **Fact Table**: `fact_orders` (measures: quantity, price, order amount)
-   **Dimension Tables**: `dim_customers`, `dim_products`, `dim_locations` (contextual data)

---

## Project Structure

```text
snowflake-sql-medallion-warehouse/
├── bronze/                      # Bronze layer: Raw data ingestion SQL
│   └── raw_tables.sql
├── silver/                      # Silver layer: Cleaning and validation SQL
│   └── refined_tables.sql
├── gold/                        # Gold layer: Fact and Dimension modeling SQL
│   └── analytical_tables.sql
├── utils/                       # Utility scripts and helper functions
├── tests/                       # Data quality and unit tests
├── _docs/                       # Documentation and architecture design
│   └── architecture_overview.md
├── images/                      # Architecture diagrams and screenshots
└── README.md                    # Project documentation
```

---

## Data Pipeline Workflow

The Medallion pipeline executes the following stages:

### 1. **Bronze: Ingest and Land**

-   Ingest raw data from source systems or stages into Bronze tables.
-   Maintain original metadata (ingestion timestamp, source file name).
-   No transformations are applied at this stage.

### 2. **Silver: Clean and Standardize**

-   Cast data types (e.g., strings to dates or decimals).
-   Handle missing values and apply data quality checks.
-   Deduplicate records based on primary keys.
-   Standardize naming conventions and formats.

### 3. **Gold: Model and Aggregate**

-   Join silver tables to create denormalized dimension tables.
-   Calculate business metrics and aggregates for fact tables.
-   Optimize tables for query performance (clustering, indexing).

---

## Setup & Installation

### Prerequisites

-   A Snowflake account (Trial or Enterprise)
-   SnowSQL or Snowflake Web UI access
-   Terraform installed (if using IaC for provisioning)

### 1. Provision Infrastructure

If using Terraform, initialize and apply the configuration:

```bash
terraform init
terraform apply
```

### 2. Configure Snowflake Connection

Ensure your credentials are set up via `~/.snowsql/config` or environment variables:

```bash
export SNOWFLAKE_ACCOUNT="your_account"
export SNOWFLAKE_USER="your_user"
export SNOWFLAKE_PASSWORD="your_password"
```

### 3. Deploy Medallion Layers

Run the SQL scripts in order:

```bash
# Deploy Bronze Layer
snowsql -f bronze/raw_tables.sql

# Deploy Silver Layer
snowsql -f silver/refined_tables.sql

# Deploy Gold Layer
snowsql -f gold/analytical_tables.sql
```

---

## Querying Data in Snowflake

Once the pipeline completes, you can query the Gold layer for insights:

### Example Queries

**1. Total Sales by Country:**

```sql
SELECT
    l.country,
    SUM(f.order_amount) AS total_sales
FROM gold.fact_orders f
JOIN gold.dim_locations l ON f.location_key = l.location_key
GROUP BY l.country
ORDER BY total_sales DESC;
```

**2. Top 5 Best Selling Product Lines:**

```sql
SELECT
    p.product_line,
    SUM(f.quantity_ordered) AS total_quantity
FROM gold.fact_orders f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_line
ORDER BY total_quantity DESC
LIMIT 5;
```

---

## Services in Action

Below are snapshots showing the Snowflake layers and data flow:

<table>
  <tr>
    <td><img src="images/image1.png" alt="Snowflake Bronze Layer" width="300"/></td>
    <td><img src="images/image2.png" alt="Snowflake Silver Layer" width="300"/></td>
    <td><img src="images/image3.png" alt="Snowflake Gold Layer" width="300"/></td>
  </tr>
</table>

---

## Let's Connect

[![WhatsApp](https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://wa.me/923074315952)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:asadali27232@gmail.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/asadali27232/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/asadali27232)
[![Facebook](https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/asadalighaffar)
[![Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/asadali27232)
[![Personal Website](https://img.shields.io/badge/Personal%20Website-24292e?style=for-the-badge&logo=react&logoColor=white&color=purple)](https://asadali27232.github.io/asadali27232)

---
