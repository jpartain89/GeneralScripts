#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LDAP_PASS="lover0778"
LDAP_CMD="ldapadd -x -D cn=admin,"
LDAP_ADDRESS="dc=jpcdi,dc=com -w ${LDAP_PASS}"
GIT_HOME="/home/jpartain89/git"

FILES=(
    "./newuser.ldif"
    "./disable_anon_bind.ldif"
)

for i in "${FILES[@]}"; do
    "${LDAP_CMD}${LDAP_ADDRESS} -f ${i}"
done
