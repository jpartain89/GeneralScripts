#!/bin/bash

# Crontab Script to auto-run git-automap

export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

LOGDIR="/var/log/git-automap"
LOGFILE="${LOGDIR}/automap_$(date '+%Y-%m-%d_%H-%M-%S').log"

[ -d "$LOGDIR" ] || sudo mkdir -p "$LOGDIR"
[ -f "$LOGFILE" ] || sudo touch "$LOGFILE"
find "$LOGDIR/" -type f -mtime +7 -exec rm {} \;

cd /home/jpartain89/git/dotfiles && /usr/local/bin/git-automap >>"$LOGFILE" 2>&1
