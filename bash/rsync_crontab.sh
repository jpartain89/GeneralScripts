#!/bin/bash -e

# Bash Script to run `flock` and `rsync_tmbackup.sh` through crontab

FLOCK="$(command -v flock)"
LOCK_FILE="/tmp/rsync.lock"
RSYNC_TMBACKUP="$(command -v rsync_tmbackup.sh)"
RSYNC_BACKUP_OPTS="-D --compress --numeric-ids --links --hard-links --one-file-system --no-itemize-changes --times --recursive --perms --owner --group"
SOURCE="/"
DEST="jpartain89@192.168.1.15:/Volumes/8TB_EXT/Backups/rpi3"
EXCLUDE_FILE="/home/jpartain89/exclude-file.txt"
LOG_FILE="/var/log/rsync-backup.log"

( "$FLOCK" -n "$LOCK_FILE" sh -c \
    "sudo bash ${RSYNC_TMBACKUP} --rsync-set-flags ${RSYNC_BACKUP_OPTS} \
    ${SOURCE} ${DEST} ${EXCLUDE_FILE} 1>${LOG_FILE} 2>&1" & ) &
