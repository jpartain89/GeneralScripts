#!/bin/bash -e

# Trying to bash-automate `sickbeard_mp4_automator`

MANUAL_FILE="/Users/jpartain89/git/sickbeard_mp4_automator/manual.py"

trap echo 'exiting', exit 1 SIGQUIT SIGTERM SIGINT

echo "Please, type the FULL path to the directory you want to work on."
read -r IN_DIRECTORY

while IFS= read -r IN_FILES; do
    "${MANUAL_FILE}" -a -nm -i "${IN_FILES}"
done < <(find "${IN_DIRECTORY}" -iname "*.mkv" -exec echo {} \;)
