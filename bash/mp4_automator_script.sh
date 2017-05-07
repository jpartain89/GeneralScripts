#!/bin/bash -e

# Trying to bash-automate `sickbeard_mp4_automator`

DIR_LOC="$1"
MANUAL_FILE="/Users/jpartain89/git/sickbeard_mp4_automator/manual.py"

trap 'echo "exiting"; exit 1' SIGQUIT SIGTERM SIGINT

[[ -z "$DIR_LOC" ]] && {
    echo "Please, type the FULL path to the directory you want to work on.";
    read -r IN_DIRECTORY
}

[[ ! -e "${MANUAL_FILE}" ]] && {
    echo "${MANUAL_FILE}"
    echo "seems to be missing, cloning through git...."
    git clone git@github.com:mdhiggins/sickbeard_mp4_automator.git "${MANUAL_FILE}"
}

while IFS= read -r IN_FILES; do
    echo "${IN_FILES}";
    "${MANUAL_FILE}" -a -nm -i "${IN_FILES}"
done < <(find "${IN_DIRECTORY}" -iname "*.mkv" -exec echo {} \;)
