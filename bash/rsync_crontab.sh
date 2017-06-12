#!/bin/bash -e

# Bash Script to run `flock` and `rsync_tmbackup.sh` through crontab

exec 1> >(logger -t "$(basename "$0")") 2>&1

REMOTE_ADDRESS="jpartain89@192.168.1.15"
REMOTE_DIR="/Volumes/2TB_RAID/Backups/rpi3"
BACK_LOC="${REMOTE_ADDRESS}:${REMOTE_DIR}"

logfile="/var/log/$(basename "$0").log"
[ -e "$logfile" ] || sudo touch "$logfile"

trap 'sudo rm -r /tmp/rsync.lock; exit 1' SIGHUP SIGINT SIGTERM EXIT

if mkdir /tmp/rsync.lock 2>/dev/null; then
    ( sudo bash "$(command -v rsync_tmbackup.sh)" \
        / "$BACK_LOC" /home/jpartain89/exclude-file.txt & ) &
else
        echo "Sorry, the lockfile currently exists. Exiting."
        exit 1
fi
