#!/usr/bin/env bash
set -e

ADDRESS="jpartain89@rpi35.jpcdi.com"
LOCAL="/media/$USER/Porn"
DIR="/media/Porn"
SSHFS="$(command -v sshfs)"
ARGUMENTS="-p 22235"

if [[ ! -f "${LOCAL}" ]]; then
    sudo mkdir -p "${LOCAL}"
fi

"${SSHFS}" "${ADDRESS}:${DIR}" "${LOCAL}" "${ARGUMENTS}"
