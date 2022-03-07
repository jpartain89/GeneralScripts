#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# Rearrange the order of options below according to what you would like to see in the help message.
# ARG_OPTIONAL_SINGLE([location], [l], [The Directory location to operate within.], )
# ARG_OPTIONAL_SINGLE([extension], [e], [The extension you want to change from to mp4. Default is mkv], [mkv])
# ARG_HELP([<The general help message of my script>])
# ARGBASH_GO

# [ <-- needed because of Argbash

# vvv  PLACE YOUR CODE HERE  vvv
# For example:
#This is to call 'transcode-video' in batch-form

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROGRAM_NAME="transcode-wrap"
REPO_NAME="generalscripts"

# This "auto-installs" git-auto into /usr/local/bin for ya!
command -v "$PROGRAM_NAME" 1>/dev/null 2>&1 || {
  (
    if [ -x "${DIR}/${PROGRAM_NAME}" ]; then
      sudo ln -svf "${DIR}/${PROGRAM_NAME}" "/usr/local/bin/${PROGRAM_NAME}"
      sudo chmod -R 0775 "/usr/local/bin/${PROGRAM_NAME}"
    else
      echo "For some reason, linking $PROGRAM_NAME to /usr/local/bin,"
      echo "failed. My apologies for not being able to figure it out..."
      exit 1
    fi
  )
}

TRANSCODE="$(command -v transcode-video)"

if [[ "${TRANSCODE}" == "" ]]; then
  echo "You don't have the necessary program."
  echo "You need to install ${TRANSCODE}"
  exit 1
fi

main() {
  while IFS= read -r file; do
    for i in "$file"; do
      cd $(dirname "$i") &&
      transcode-video --quick --mp4 "$(basename "$i")" \
        "$(basename "${i%"${_arg_extension}"}mp4")" &&
      cd "${DIR}";
    done;
  done< <(find "$_arg_location" -iname "*.${_arg_extension}" -exec echo {} \;)
}

main

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
