#!/bin/bash -e

# Bash Script to run `rsync_tmbackup.sh` through crontab

REMOTE_ADDRESS="jpartain89@192.168.1.15"
REMOTE_DIR="/Volumes/8TB_EXT/Backups/rpi35/"
BACK_LOC="${REMOTE_ADDRESS}:${REMOTE_DIR}"

logfile="/var/log/$(basename "$0").log"
[ -e "$logfile" ] || sudo touch "$logfile"

trap 'exit 1' SIGHUP SIGINT SIGTERM

{ echo "";
echo "";
echo "Started at $(date '+%m-%d-%Y %H:%M:%S')";
echo "";
echo ""; } | sudo tee -a "$logfile"

sudo bash -ex "$(command -v rsync_tmbackup.sh)" \
        / "$BACK_LOC" /home/jpartain89/exclude-file.txt 2>&1 | sudo tee -a "$logfile" && \

{ echo "";
echo "";
echo "Ended at $(date '+%m-%d-%Y %H:%M:%S')";
echo "";
echo ""; } | sudo tee -a "$logfile"
