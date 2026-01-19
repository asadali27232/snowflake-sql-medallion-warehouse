#!/bin/bash

# Configuration
S3_BUCKET="s3://snowflake-sql-medallion-warehouse/bronze"
SOURCE_DIR="data"

echo "-------------------------------------------------------"
echo "🚀 Starting S3 Data Ingestion..."
echo "-------------------------------------------------------"

# Environment Check
if ! command -v aws &> /dev/null; then
    echo "❌ Error: AWS CLI not found."
    exit 1
fi

# Validation
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Execution
# Using 'sync' with '--delete' ensures S3 is a mirror of the local directory.
# We removed '--size-only' to ensure it overwrites files if timestamps or content differ.
echo "🔄 Syncing local $SOURCE_DIR to $S3_BUCKET..."
aws s3 sync "$SOURCE_DIR" "$S3_BUCKET" --delete

if [ $? -eq 0 ]; then
    echo "-------------------------------------------------------"
    echo "✅ Success: Data ingestion completed."
    echo "-------------------------------------------------------"
else
    echo "-------------------------------------------------------"
    echo "❌ Error: S3 sync failed."
    echo "-------------------------------------------------------"
    exit 1
fi
