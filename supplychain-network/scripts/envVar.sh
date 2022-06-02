#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export PEER0_ORG_MANUFACTURER_CA=${PWD}/organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem
export PEER0_ORG_MIDDLEMEN_CA=${PWD}/organizations/peerOrganizations/middlemen.example.com/tlsca/tlsca.middlemen.example.com-cert.pem
export PEER0_ORG_CONSUMER_CA=${PWD}/organizations/peerOrganizations/consumer.example.com/tlsca/tlsca.consumer.example.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [[ ${USING_ORG} == ".manufacturer" ]]; then
    export CORE_PEER_LOCALMSPID="OrgManufacturerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG_MANUFACTURER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [[ ${USING_ORG} == ".middlemen" ]]; then
    export CORE_PEER_LOCALMSPID="OrgMiddlemenMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG_MIDDLEMEN_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

  elif [[ ${USING_ORG} == ".consumer" ]]; then
    export CORE_PEER_LOCALMSPID="OrgConsumerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG_CONSUMER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/consumer.example.com/users/Admin@consumer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [[ ${USING_ORG} == ".manufacturer" ]]; then
    export CORE_PEER_ADDRESS=peer0.org.manufacturer.example.com:7051
  elif [[ ${USING_ORG} == ".middlemen" ]]; then
    export CORE_PEER_ADDRESS=peer0.org.middlemen.example.com:9051
  elif [[ ${USING_ORG} == ".consumer" ]]; then
    export CORE_PEER_ADDRESS=peer0.org.consumer.example.com:11051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    
    if [[ $1 == ".manufacturer" ]]; then
      CA=PEER0_ORG_MANUFACTURER_CA
    elif [[ $1 == ".middlemen" ]]; then
      CA=PEER0_ORG_MIDDLEMEN_CA
    elif [[ $1 == ".consumer" ]]; then
      CA=PEER0_ORG_CONSUMER_CA
    else
      errorln "ORG Unknown"
  fi
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
