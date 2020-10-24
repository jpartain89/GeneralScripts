#!/usr/bin/env bash
set -e

function remove() {
    echo "Removing the entire /usr/local/go directory"
    sudo rm -r "${GOROOT}"
}
function install() {
    local GOLANG="$(curl https://golang.org/dl/ | \
        grep armv6l | \
        grep -v beta | \
        head -1 | \
        awk -F\> {'print $3'} | \
        awk -F\< {'print $1'})"

    wget -O - "https://golang.org/dl/$GOLANG" | sudo tar -C /usr/local -zxvf -
}


if [[ -d /usr/local/go ]]; then
    GOROOT="$(go env GOROOT)"
    echo "You already have an installation of GO at /usr/local/go"
    echo "Do you want to remove it and upgrade? Or quit the download?"
    echo "1 for Remove and Upgrade, 2 for Quit"

    read -r INSTALL_CONFIRM
    case $INSTALL_CONFIRM in
        1 | I | install )
            remove;
            install;;
        2 | q | quit )
            exit 0;;
    esac
fi

