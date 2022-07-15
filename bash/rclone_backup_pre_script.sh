#!/usr/bin/env bash
set -e

# program info
PROGRAM_NAME="rclone_backup_pre_script.sh"
REPO_NAME="generalscripts"
VERSION="0.0.1"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

eval ~/git/generalscripts/bash/functions/bash_functions

_die
_trap_die
_trap
_link_install

SSDC=$(command -v ssdc)

"${SSDC} backup"

sudo mariadb-dump -ujpartain89 -plover0778 --all-databases --flush-privileges -f > /docker/mariadb/backup/$(date +%F_%R).sql 2>/dev/null
