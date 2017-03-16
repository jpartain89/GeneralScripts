#!/bin/bash -e

# Crontab Script to auto-run git-automap

export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

cd /home/jpartain89/git/dotfiles && /usr/local/bin/git-automap || exit 1 \
  >>"/var/log/git-automap/$(date '+%Y-%m-%d_%H-%M-%S').log" 2>&1
