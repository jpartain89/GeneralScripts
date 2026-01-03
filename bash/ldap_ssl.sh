#!/usr/bin/env bash

# copied from https://documentation.ubuntu.com/server/how-to/openldap/ldap-and-tls/

SSL_ETC_DIR="/etc/ssl"
LDAP_SERVER_FILENAME="syno01"
SSL_PRIVATE_DIR="${SSL_ETC_DIR}/private" # directory for private keys
LDAP_LDIF_DIR="/etc/ldap/ldif" # directory for LDAP ldif files
SSL_CERTS_DIR="${SSL_ETC_DIR}/certs" # directory for certificates
SSL_PRIV_KEY="${SSL_PRIVATE_DIR}/The_CA_Key.pem" # private key for the CA
SSL_CA_CERT="${SSL_CERTS_DIR}/The_CA_Cert.crt" # self-signed CA certificate
SSL_LDAP_KEY="/etc/ldap/${LDAP_SERVER_FILENAME}_slapd_key.pem" # private key for LDAP server
SSL_SERVER_CERT="/etc/ldap/${LDAP_SERVER_FILENAME}_slapd_cert.pem" # certificate for LDAP server
COMPANY="JPCDI"
EXPIRATION_DAYS="3650"
KEY_BITS="4096"

# This script configures LDAP to use SSL/TLS for secure communication.
sudo apt install gnutls-bin ssl-cert

# Create a private key for the Certificate Authority
sudo certtool --generate-privkey --bits 4096 --outfile "${SSL_PRIV_KEY}"

#Create the template/file /etc/ssl/ca.info to define the CA
cn = ${COMPANY}
ca
cert_signing_key
expiration_days = ${EXPIRATION_DAYS}

# Create the self-signed CA certificate
sudo certtool --generate-self-signed \
  --load-privkey "${SSL_PRIV_KEY}" \
  --template /etc/ssl/ca.info \
  --outfile "${SSL_CA_CERT}"

# Run update-ca-certificates to add the new CA certificate to the list of trusted CAs. Note the one added CA:
sudo update-ca-certificates

# Make a private key for the server
sudo certtool --generate-privkey \
  --bits ${KEY_BITS} \
  --outfile "${SSL_LDAP_KEY}"

# Create /etc/ssl/${LDAP_SERVER_FILENAME}.info
# The following certificate is good for 1 year, and it’s valid
# only for the ${LDAP_SERVER_FILENAME}.jpcdi.com hostname
# You can adjust this according to your needs
cat << EOF | sudo tee "/etc/ssl/${LDAP_SERVER_FILENAME}.info"
organization = ${COMPANY}
cn = ${LDAP_SERVER_FILENAME}.jpcdi.com
tls_www_server
encryption_key
signing_key
expiration_days = 365
EOF

# Create the server’s certificate:
sudo certtool --generate-certificate \
  --load-privkey "${SSL_LDAP_KEY}" \
  --load-ca-certificate "${SSL_CA_CERT}" \
  --load-ca-privkey "${SSL_PRIV_KEY}" \
  --template "/etc/ssl/${LDAP_SERVER_FILENAME}.info" \
  --outfile "${SSL_SERVER_CERT}"

# Adjust permissions and ownership:
sudo chgrp openldap "${SSL_LDAP_KEY}"
sudo chmod 0640 "${SSL_LDAP_KEY}"

#echo << EOF | sudo tee "${LDAP_LDIF_DIR}/certinfo.ldif"
#dn: cn=config
#add: olcTLSCACertificateFile
#olcTLSCACertificateFile: "${SSL_CA_CERT}"
#-
#add: olcTLSCertificateFile
#olcTLSCertificateFile: "/etc/ldap/${LDAP_SERVER_FILENAME}_slapd_cert.pem"
#-
#add: olcTLSCertificateKeyFile
#olcTLSCertificateKeyFile: "/etc/ldap/${LDAP_SERVER_FILENAME}_slapd_key.pem"
#EOF
#
#
#sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f "${LDAP_LDIF_DIR}/certinfo.ldif"

sudo rsync -avhP \
  "${SSL_LDAP_KEY}" \
  "${SSL_SERVER_CERT}" \
  "${SSL_CA_CERT}" \
  /media/General/ssl_certs/