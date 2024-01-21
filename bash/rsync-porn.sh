#!/usr/bin/env bash
set -e

# This script will be to auto-sync/move the syncthing-downloaded
# porn from their starting location inside of my `syncthing` directory
# and into their final destination.

PROGRAM_NAME="rsync-porn.sh"
#REPO_NAME="generalscripts"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

command -v "$PROGRAM_NAME" 1>/dev/null 2>&1 || {
  (
    if [ -x "${DIR}/${PROGRAM_NAME}" ]; then
      sudo ln -svf "${DIR}/${PROGRAM_NAME}" "/usr/local/bin/${PROGRAM_NAME}"
      sudo chmod -R 0775 "/usr/local/bin/${PROGRAM_NAME}"
    else
      echo "For some reason, linking ${PROGRAM_NAME} to /usr/local/bin,"
      echo "failed. My apologies for not being able to figure it out..."
      exit 1
    fi
  )
}

# Setting these variables prior to sourcing the config files that may or may not exist.
# This way, if they don't, then the defaults listed below still hold true.
FROM="/media/Downloads/syncthing"
DESTINATION_ONE="/media/Porn"
DESTINATION_TWO="/media/8TB/Porn"

# this gives preference from top to bottom, aka:
# if /etc/rsync-porn.conf is found first, then it stops looking any further
if [[ -f /etc/rsync-porn.conf ]]; then
    CONFIG_FILE=/etc/rsync-porn.conf
    source "${CONFIG_FILE}"
elif [[ -f /etc/rsync-porn/rsync-porn.conf ]]; then
    CONFIG_FILE=/etc/rsync-porn/rsync-porn.conf
    source "${CONFIG_FILE}"
elif [[ -f "${HOME}/rsync-porn.conf" ]]; then
    CONFIG_FILE="${HOME}/rsync-porn.conf"
    source "${CONFIG_FILE}"
elif [[ -f "${HOME}/.config/rsync-porn.conf" ]]; then
    CONFIG_FILE="${HOME}/.config/rsync-porn.conf"
    source "${CONFIG_FILE}"
elif [[ -f "${HOME}/git/docker_directory/rsync-porn.conf" ]]; then
    CONFIG_FILE="${HOME}/git/docker_directory/rsync-porn.conf"
    source "${CONFIG_FILE}"
else
    cat << EOF > "${HOME}/.config/rsync-porn.conf"
FROM="/media/Downloads/syncthing"
DESTINATION_ONE="/media/Porn"
DESTINATION_TWO="/media/8TB/Porn"
EOF
fi

die() {
    echo "$PROGRAM_NAME: $1" >&2
    exit "${2:-1}"
}

trap "die 'trap called'" SIGHUP SIGINT SIGTERM

help() {
  cat << EOF
  Usage: rsync-porn.sh [ --dir | -d ] | [ --search-term | -st ] | [ --from ]

  --dir :  This is the ending name of the directory that you want the file to end up inside of.
  --iname :  These match \`find\`'s style of "-iname" and "-name" flags, and the word after is the search term.
  --from    : Defaults to /media/Downloads/syncthing, but using this, you can set it to any location.
EOF
}

FIND_CMD() {
  find "${FROM}" "${SEARCH_TYPE}" "${NAME_OF_FILE}" -exec echo {} \;
}

main() {
  while IFS= read -r file; do
    for i in "${file[@]}"; do
      rsync -avhP "${i}" "${DESTINATION_ONE}/${TO_DIR}" &&
      rsync -avhP --remove-source-files "${i}" "${DESTINATION_TWO}/${TO_DIR}"
    done;
  done< <(FIND_CMD) && \
    exit 0
}

has_argument() {
  [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help )
            help;
            exit 0;;
    --dir* )
            if ! has_argument $@; then
              echo "Directory not Specified." >&2;
              help
              exit 1
            fi
            TO_DIR=$(extract_argument "$@");
            shift;;
    --iname )
            SEARCH_TYPE="-iname";
            NAME_OF_FILE=$(extract_argument "$@");
            shift;;
    --from )
            FROM=$(extract_argument "$@");
            shift;;
    --* | -* | * )
            help;
            exit 2;;
  esac
done

main &&
exit 0
