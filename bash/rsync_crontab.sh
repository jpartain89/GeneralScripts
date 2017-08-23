#!/bin/bash -e

# Bash Script to run `rsync_tmbackup.sh` through crontab

#REMOTE_ADDRESS="jpartain89@192.168.1.15"
REMOTE_DIR="/media/BigPartition/Backups/rpi3"
#BACK_LOC="${REMOTE_ADDRESS}:${REMOTE_DIR}"

logfile="/var/log/$(basename "$0").log"
[ -e "$logfile" ] || sudo touch "$logfile"

trap 'exit 1' SIGHUP SIGINT SIGTERM

( sudo bash "$(command -v rsync_tmbackup.sh)" \
        / "$BACK_LOC" /home/jpartain89/exclude-file.txt & ) &
