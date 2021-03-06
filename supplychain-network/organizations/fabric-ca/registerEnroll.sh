#!/bin/bash

function createOrgManufacturer() {
  infoln "Enrolling the CA-Org-Manufacturer admin"
  mkdir -p organizations/peerOrganizations/manufacturer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org-manufacturer --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org-manufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org-manufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org-manufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org-manufacturer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orgManufacturer's CA cert to orgManufacturer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/tlscacerts/ca.crt"

  # Copy orgManufacturer's CA cert to orgManufacturer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/tlsca/tlsca.manufacturer.example.com-cert.pem"

  # Copy orgManufacturer's CA cert to orgManufacturer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/ca/ca.manufacturer.example.com-cert.pem"

  infoln "Registering peer0manufacturer"
  set -x
  fabric-ca-client register --caname ca-org-manufacturer --id.name peer0manufacturer --id.secret peer0manufacturerpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # TODO not sure about that
  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org-manufacturer --id.name partner --id.secret partnerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org-manufacturer --id.name orgManufacturerAdmin --id.secret orgmanufactureradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0manufacturer msp"
  set -x
  fabric-ca-client enroll -u https://peer0manufacturer:peer0manufacturerpw@localhost:7054 --caname ca-org-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/msp" --csr.hosts peer0.org.manufacturer.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/msp/config.yaml"

  infoln "Generating the peer0manufacturer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0manufacturer:peer0manufacturerpw@localhost:7054 --caname ca-org-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/tls" --enrollment.profile tls --csr.hosts peer0.org.manufacturer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.example.com/peers/peer0.org.manufacturer.example.com/tls/server.key"

  # TODO not sure about that
  infoln "Generating the partner msp"
  set -x
  fabric-ca-client enroll -u https://partner:partnerpw@localhost:7054 --caname ca-org-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/partner@manufacturer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/partner@manufacturer.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://orgManufacturerAdmin:orgmanufactureradminpw@localhost:7054 --caname ca-org-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/Admin@manufacturer.example.com/msp/config.yaml"

  # ---------
  # TODO not sure about that
  
  infoln "Registering the org 1-customer "
  set -x
  fabric-ca-client register --caname ca-org-manufacturer --id.name customer --id.secret customerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the org 1 customer msp"
  set -x
  fabric-ca-client enroll -u https://customer:customerpw@localhost:7054 --caname ca-org-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/customer@manufacturer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgManufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/manufacturer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.example.com/users/customer@manufacturer.example.com/msp/config.yaml"

  # ---------
}

function createOrgMiddlemen() {
  infoln "Enrolling the CA-Org-Middlemen admin"
  mkdir -p organizations/peerOrganizations/middlemen.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/middlemen.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org-middlemen --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org-middlemen.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org-middlemen.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org-middlemen.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org-middlemen.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/middlemen.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orgMiddlemen's CA cert to orgMiddlemen's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/middlemen.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem" "${PWD}/organizations/peerOrganizations/middlemen.example.com/msp/tlscacerts/ca.crt"

  # Copy orgMiddlemen's CA cert to orgMiddlemen's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/middlemen.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem" "${PWD}/organizations/peerOrganizations/middlemen.example.com/tlsca/tlsca.middlemen.example.com-cert.pem"

  # Copy orgMiddlemen's CA cert to orgMiddlemen's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/middlemen.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem" "${PWD}/organizations/peerOrganizations/middlemen.example.com/ca/ca.middlemen.example.com-cert.pem"

  infoln "Registering peer0manufacturer"
  set -x
  fabric-ca-client register --caname ca-org-middlemen --id.name peer0manufacturer --id.secret peer0manufacturerpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org-middlemen --id.name partner --id.secret partnerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org-middlemen --id.name orgMiddlemenAdmin --id.secret orgmiddlemenadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0manufacturer msp"
  set -x
  fabric-ca-client enroll -u https://peer0manufacturer:peer0manufacturerpw@localhost:8054 --caname ca-org-middlemen -M "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/msp" --csr.hosts peer0.org.middlemen.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/middlemen.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/msp/config.yaml"

  infoln "Generating the peer0manufacturer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0manufacturer:peer0manufacturerpw@localhost:8054 --caname ca-org-middlemen -M "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/tls" --enrollment.profile tls --csr.hosts peer0.org.middlemen.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/middlemen.example.com/peers/peer0.org.middlemen.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://partner:partnerpw@localhost:8054 --caname ca-org-middlemen -M "${PWD}/organizations/peerOrganizations/middlemen.example.com/users/partner@middlemen.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/middlemen.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/middlemen.example.com/users/partner@middlemen.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://orgMiddlemenAdmin:orgmiddlemenadminpw@localhost:8054 --caname ca-org-middlemen -M "${PWD}/organizations/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/middlemen.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/middlemen.example.com/users/Admin@middlemen.example.com/msp/config.yaml"

  # ---------
  # TODO idk about these

  infoln "Registering the org 2-customer"
  set -x
  fabric-ca-client register --caname ca-org-middlemen --id.name customer --id.secret customerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the org 2-customer msp"
  set -x
  fabric-ca-client enroll -u https://customer:customerpw@localhost:8054 --caname ca-org-middlemen -M "${PWD}/organizations/peerOrganizations/middlemen.example.com/users/customer@middlemen.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgMiddlemen/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/middlemen.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/middlemen.example.com/users/customer@middlemen.example.com/msp/config.yaml"
  
  # ---------
}

function createOrderer() {
  infoln "Enrolling the CA-Orderer admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}

function createOrgConsumer {
	infoln "Enrolling the CA-Org-Consumer admin"
	mkdir -p ../organizations/peerOrganizations/consumer.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/consumer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-org-consumer --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-org-consumer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-org-consumer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-org-consumer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-org-consumer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/consumer.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orgConsumer's CA cert to orgConsumer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/consumer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/consumer.example.com/msp/tlscacerts/ca.crt"

  # Copy orgConsumer's CA cert to orgConsumer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/consumer.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/consumer.example.com/tlsca/tlsca.consumer.example.com-cert.pem"

  # Copy orgConsumer's CA cert to orgConsumer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/consumer.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/consumer.example.com/ca/ca.consumer.example.com-cert.pem"

	infoln "Registering peer0consumer"
  set -x
	fabric-ca-client register --caname ca-org-consumer --id.name peer0consumer --id.secret peer0consumerpw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-org-consumer --id.name partner --id.secret partnerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org-consumer --id.name orgConsumerAdmin --id.secret orgconsumeradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0consumer msp"
  set -x
	fabric-ca-client enroll -u https://peer0consumer:peer0consumerpw@localhost:11054 --caname ca-org-consumer -M "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/msp" --csr.hosts peer0.org.consumer.example.com --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/msp/config.yaml"


  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0consumer:peer0consumerpw@localhost:11054 --caname ca-org-consumer -M "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/tls" --enrollment.profile tls --csr.hosts peer0.org.consumer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/consumer.example.com/peers/peer0.org.consumer.example.com/tls/server.key"


  infoln "Generating the partner msp"
  set -x
	fabric-ca-client enroll -u https://partner:partnerpw@localhost:11054 --caname ca-org-consumer -M "${PWD}/organizations/peerOrganizations/consumer.example.com/users/partner@consumer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.example.com/users/partner@consumer.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
	fabric-ca-client enroll -u https://orgConsumerAdmin:orgconsumeradminpw@localhost:11054 --caname ca-org-consumer -M "${PWD}/organizations/peerOrganizations/consumer.example.com/users/Admin@consumer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.example.com/users/Admin@consumer.example.com/msp/config.yaml"

  infoln "Registering the org consumer-customer"
  set -x
  fabric-ca-client register --caname ca-org-consumer --id.name customer --id.secret customerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the org consumer-customer msp"
  set -x
  fabric-ca-client enroll -u https://customer:customerpw@localhost:11054 --caname ca-org-consumer -M "${PWD}/organizations/peerOrganizations/consumer.example.com/users/customer@consumer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orgConsumer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/consumer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/consumer.example.com/users/customer@consumer.example.com/msp/config.yaml"
  
}
