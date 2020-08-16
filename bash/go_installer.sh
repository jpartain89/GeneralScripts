#!/usr/bin/env bash
set -e

if [[ -d /usr/local/go ]]; then
    echo "You already have an installation of GO at /usr/local/go"
    echo "Do you want to remove it and upgrade? Or quit the download?"
    read -r INSTALL_CONFIRM

        

local GOLANG="$(curl https://golang.org/dl/ | \
    grep armv6l | \
    grep -v beta | \
    head -1 | \
    awk -F\> {'print $3'} | \
    awk -F\< {'print $1'})"

wget -O - "https://golang.org/dl/$GOLANG" | sudo tar -C /usr/local -zxvf -
