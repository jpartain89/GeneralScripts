#!/bin/bash -e

# Bash Script to run `flock` and `rsync_tmbackup.sh` through crontab

LOG_FILE="/var/log/rsync-backup.log"
[  ! -e "${LOG_FILE}" ] && sudo touch "${LOG_FILE}"
sudo chmod -R 0664 "${LOG_FILE}"

trap 'sudo rm /tmp/rsync.lock; exit 1' SIGHUP SIGINT SIGTERM

( "$(command -v flock)" -n /tmp/rsync.lock sh -c \
    "sudo bash $(command -v rsync_tmbackup.sh) \
    / jpartain89@192.168.1.15:/Volumes/8TB_EXT/Backups/rpi3 \
    /home/jpartain89/exclude-file.txt 1>> ${LOG_FILE} 2>&1" & ) &
