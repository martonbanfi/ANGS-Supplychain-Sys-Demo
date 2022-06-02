#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using orgManufacturer
ORG=${1:-orgManufacturer}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/test-network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
PEER0_ORG_MANUFACTURER_CA=${DIR}/test-network/organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem
PEER0_ORG_MIDDLEMEN_CA=${DIR}/test-network/organizations/peerOrganizations/middlemen.example.com/tlsca/tlsca.middlemen.example.com-cert.pem
PEER0_ORG_CONSUMER_CA=${DIR}/test-network/organizations/peerOrganizations/consumer.example.com/tlsca/tlsca.consumer.example.com-cert.pem


if [[ ${ORG} == "orgManufacturer" ]]; then

   CORE_PEER_LOCALMSPID=OrgManufacturerMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem

elif [[ ${ORG} == "orgMiddlemen"]]; then

   CORE_PEER_LOCALMSPID=OrgMiddlemenMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp
   CORE_PEER_ADDRESS=localhost:9051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/middlemen.example.com/tlsca/tlsca.middlemen.example.com-cert.pem

elif [[ ${ORG} == "orgConsumer" ]]; then

   CORE_PEER_LOCALMSPID=OrgConsumerMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/consumer.example.com/users/Admin@consumer.example.com/msp
   CORE_PEER_ADDRESS=localhost:9051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/consumer.example.com/tlsca/tlsca.consumer.example.com-cert.pem

else
   echo "Unknown \"$ORG\", please choose OrgManufacturer or OrgConsumer"
   echo "For example to get the environment variables to set upa OrgConsumer shell environment run:  ./setOrgEnv.sh OrgConsumer"
   echo
   echo "This can be automated to set them as well with:"
   echo
   echo 'export $(./setOrgEnv.sh OrgConsumer | xargs)'
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_ORG_MANUFACTURER_CA=${PEER0_ORG_MANUFACTURER_CA}"
echo "PEER0_ORG_MIDDLEMEN_CA=${PEER0_ORG_MIDDLEMEN_CA}"
echo "PEER0_ORG_CONSUMER_CA=${PEER0_ORG_CONSUMER_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"
