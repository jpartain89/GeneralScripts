#!/bin/bash

BLOCKLIST=/usr/local/var/transmission/blocklists/jp_full.txt

# Link good as of June 2018
# Download lists, unpack and filter, write to stdout
curl -s https://www.iblocklist.com/lists.php \
    | sed -n "s/.*value='\(http:.*\?list=.*\)'.*/\1/p" \
    | xargs wget -O - \
    | gunzip \
    | grep -ev '^#' > "$BLOCKLIST" 2>/dev/null &
