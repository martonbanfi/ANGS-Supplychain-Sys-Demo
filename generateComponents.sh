#!/bin/bash
#
# Generates TS entities based on the entity definition
# Usage: ./genComp.sh
set -e

COMPONENT_FILE=supplychain-system-components.yaml
CHAINCODE_MODEL_DIR=/src/chaincode/contract/src               # Relative to mounted volume in docker container
ROUTER_MODEL_DIR=/src/supplychain-system-router/src                # Relative to mounted volume in docker container
ROUTER_OPENAPI_DIR=supplychain-system-router/src/config/openapi/   # Relative to local dir
WEBSITE_MODEL_DIR=/src/supplychain-system-website

echo Generate models for chaincode...
docker run -t --rm -v $(pwd):/src swagger-codegen-cli generate \
  -i /src/$COMPONENT_FILE \
  -Dmodels \
  -l typescript-angular \
  -o $CHAINCODE_MODEL_DIR

echo Generate models for router...
docker run -t --rm -v $(pwd):/src swagger-codegen-cli generate \
  -i /src/$COMPONENT_FILE \
  -Dmodels \
  -l typescript-angular \
  -o $ROUTER_MODEL_DIR  

echo Generate models for website...
docker run -t --rm -v $(pwd):/src swagger-codegen-cli generate \
  -i /src/$COMPONENT_FILE \
  -Dmodels \
  -l typescript-angular \
  -o $WEBSITE_MODEL_DIR  

echo Copy components to OpenAPI folder...
cp $COMPONENT_FILE $ROUTER_OPENAPI_DIR
echo Done.