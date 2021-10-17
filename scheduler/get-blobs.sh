#!/bin/bash
# This script grabs blobs about hostpool information and creates a CSV file mapping the hostpool and its resource group.

# ---- Dependencies ---- #
# Note that jq is a dependency of this script.
# Install with `sudo apt-get install -y jq`
#FIXME: set -e

#FIXME: Remove me when done and uncomment block below
sudo apt-get install -yq jq
# if ! command -v jq &> /dev/null
# then
#     echo "jq is not installed, please ensure jq is installed"
#     exit 1
# fi

# ---- Required Environment Variables ---- #
# STORAGE_ACCOUNT_NAME   -> Name of the storage account where the blob is stored.
# STORAGE_CONTAINER_NAME -> Name of the storage container where the blob is stored.

# ---- Optional Environment Variables ---- #
# LOCAL_BLOB_STORE_LOCATION -> Location on local machine to download the blobs to.

if [[ -z "${STORAGE_ACCOUNT_NAME}" ]]; then
  echo "STORAGE_ACCOUNT_NAME is not set, please set this value"
  exit 1
fi

if [[ -z "${STORAGE_CONTAINER_NAME}" ]]; then
  echo "STORAGE_CONTAINER_NAME is not set, please set this value"
  exit 1
fi

# Set working directory
BLOB_LOCATION="${LOCAL_BLOB_STORE_LOCATION:-./blobs}"
mkdir -p $BLOB_LOCATION

# Download blobs
blobs=$(az storage blob download-batch \
          --destination $BLOB_LOCATION \
          --source $STORAGE_CONTAINER_NAME \
          --account-name $STORAGE_ACCOUNT_NAME \
          --account-key $( \
              az storage account keys list \
              --account-name $STORAGE_ACCOUNT_NAME \
              | jq '.[0].value' \
          ) \
        )

# Map to array
mapfile -t files < <(jq -r '.[]' <<< "$blobs")
# declare -p files

# Building CSV file with contents from blobs
echo "resource_group,hostpool" > hostpools.csv
# Loop and process each file
for file in "${files[@]}"; do
  file_location="$BLOB_LOCATION/$file"
  echo "Processing $BLOB_LOCATION/$file"

  resource_group=$(cat $file_location | cut -d, -f1)
  hostpool=$(cat $file_location | cut -d, -f2)

  echo "$resource_group,$hostpool" >> hostpools.csv
done

echo "Done"