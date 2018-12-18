#!/usr/bin/env sh

# Link good as of June 2018
# Download lists, unpack and filter, write to stdout
curl -s https://www.iblocklist.com/lists.php \
  | sed -n "s/.*value='\(http:.*\?list=.*\)'.*/\1/p" \
  | xargs wget -O - \
  | gunzip \
  | egrep -v '^#'
