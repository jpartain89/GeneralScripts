#!/usr/bin/env bash
set -e

# This script will be to auto-sync/move the syncthing-downloaded
# porn from their starting location inside of my `syncthing` directory
# and into their final destination.

PROGRAM_NAME="rsync-porn.sh"
REPO_NAME="generalscripts"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## This is the standard directory where your files that you always
## want moved from and to are stored

FROM="/media/Downloads/syncthing"
TO_1="/media/Porn"
TO_2="/media/8TB/Porn"

die() {
    echo "$PROGRAM_NAME: $1" >&2
    exit "${2:-1}"
}

trap "die 'trap called'" SIGHUP SIGINT SIGTERM

help() {
  cat << EOF
  Usage: rsync-porn.sh [ --dir | -d ] | [ --search-term | -st ] | [ --from ]

  -d | --dir :  This is the ending name of the directory that you want the file to end up inside of.
  -st | --search-term :  This is the word that you want to use to search and then move multiple files over.
  --from    : Defaults to /media/Downloads/syncthing, but using this, you can set it to any location.
EOF
}

FIND_CMD() {
  find "${FROM}" -iname "${NAME_OF_FILE}" -exec echo {} \;
}

main() {
  while IFS= read -r file; do
    for i in "${file}"; do
      rsync -avhP "${i}" "${TO_1}/${TO_DIR}" &&
      rsync -avhP --remove-source-files "${i}" "${TO_2}/${TO_DIR}"
    done;
  done< <(FIND_CMD)
}

if [ $# == 0 ] ; then
  help
  trap
fi

while (( "$#" )); do
  case "$1" in
    -d | --dir )
            TO_DIR=$2;
            shift;;
    -st | --search-term )
            NAME_OF_FILE=$2;
            shift;;
    --from )
            FROM=$2;
            shift;;
  esac
  main
done
