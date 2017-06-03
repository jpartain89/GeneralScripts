#!/bin/bash -e

# Bash Script to run `flock` and `rsync_tmbackup.sh` through crontab

exec 1> >(logger -t "$(basename "$0")") 2>&1

logfile="/var/log/$(basename "$0").log"
[ -e "$logfile" ] || sudo touch "$logfile"

trap 'sudo rm -r /tmp/rsync.lock; exit 1' SIGHUP SIGINT SIGTERM EXIT

if mkdir /tmp/rsync.lock 2>/dev/null; then
    ( sudo bash "$(command -v rsync_tmbackup.sh)" \
        / jpartain89@192.168.1.15:/Volumes/8TB_EXT/Backups/rpi3 \
        /home/jpartain89/exclude-file.txt & ) &
else
        echo "Sorry, the lockfile currently exists. Exiting."
        exit 1
fi
