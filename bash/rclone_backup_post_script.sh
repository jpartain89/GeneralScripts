#!/usr/bin/env bash
set -e

# program info
PROGRAM_NAME="rclone_backup_post_script.sh"
REPO_NAME="generalscripts"
VERSION="0.0.1"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ~/git/generalscripts/bash/functions/bash_functions

_link_install

SSDC=$(command -v ssdc)

${SSDC} start
