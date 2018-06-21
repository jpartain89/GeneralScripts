#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LDAP_PASS="lover0778"
LDAP_CMD="ldapadd -x -W -D cn=admin,"
LDAP_ADDRESS="dc=jpcdi,dc=com -w ${LDAP_PASS}"
GIT_HOME="/home/jpartain89/git"

FILES=(
    "${DIR}/newuser.ldif"
    "${DIR}/disable_anon_bind.ldif"
)

for i in "${FILES[@]}"; do
    "${LDAP_CMD}${LDAP_ADDRESS} -f ${i}"
done

git clone https://github.com/leenooks/phpLDAPadmin.git "${GIT_HOME}/phpldapadmin"
cp "${GIT_HOME}phpldapadmin/config/config.php{.example,}"
