#!/bin/bash -e

# Bash Script to run `flock` and `rsync_tmbackup.sh` through crontab

logfile="/var/log/$(basename "$0").log"
[ -e "$logfile" ] || sudo touch "$logfile"

trap 'sudo rm /tmp/rsync.lock; exit 1' SIGHUP SIGINT SIGTERM EXIT

(
    "$(command -v flock)" -n 8 || exit 1
        ( sudo bash "$(command -v rsync_tmbackup.sh)" \
        / jpartain89@192.168.1.15:/Volumes/8TB_EXT/Backups/rpi3 \
        /home/jpartain89/exclude-file.txt & ) &> "$logfile" 2>&1
) 8> /tmp/rsync.lock
