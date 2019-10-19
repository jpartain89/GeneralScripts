#!/usr/bin/env bash
set -e

# Program Info
PROGRAM_NAME="vm-auto-snapshot"
REPO_NAME="generalscripts"
VERSION="1.0.0"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH="/usr/local/Cellar/python/3.7.4_1/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

die() {
    echo "$PROGRAM_NAME: $1" >&2
    exit "${2:-1}"
}

trap "die 'trap called'" SIGHUP SIGINT SIGTERM

command -v "$PROGRAM_NAME" 1>/dev/null 2>&1 || {
    (
        if [ -x "${DIR}/${PROGRAM_NAME}" ]; then
            sudo ln -svf "${DIR}/${PROGRAM_NAME}" "/usr/local/bin/${PROGRAM_NAME}"
            sudo chmod -R 0775 "/usr/local/bin/${PROGRAM_NAME}"
        else
            echo "For some reason, linking ${PROGRAM_NAME} to /usr/local/bin,"
            echo "failed. My apologies for not being able to figure it out..."
            exit 1
        fi
    )
}

/usr/local/opt/python3/bin/python3 \
    /Users/jpartain89/src/bw-plex/bw_plex/cli.py \
    --debug watch > /Users/jpartain89/Library/Logs/bw_plex.log 2>&1
