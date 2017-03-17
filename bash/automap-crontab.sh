#!/bin/bash

# Crontab Script to auto-run git-automap

export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

LOGDIR="/var/log/git-automap"
LOGFILE="${LOGDIR}/$(date '+%Y-%m-%d_%H-%M-%S').log"

[ -d "$LOGDIR" ] || sudo mkdir -p "$LOGDIR"
[ -f "$LOGFILE" ] || sudo touch "$LOGFILE"j

cd /home/jpartain89/git/dotfiles && /usr/local/bin/git-automap >>"$LOGFILE" 2>&1
