#!/bin/bash

BLOCKLIST=/var/www/html/public/jp_full.txt

main() {
    # Link good as of June 2018
    # Download lists, unpack and filter, write to stdout
    curl -s https://www.iblocklist.com/lists.php \
        | sed -n "s/.*value='\(http:.*\?list=.*\)'.*/\1/p" \
        | xargs wget -O - \
        | gunzip \
        | egrep -v '^#'
}

main > "$BLOCKLIST" 2>/dev/null &
