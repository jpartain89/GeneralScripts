#!/usr/bin/env bash
set -e

PROGRAM_NAME=synctorrents
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_NAME="generalscripts"

die() {
  cd ${DIR}
  echo "$PROGRAM_NAME: $1" >&2
  exit "${2:-1}"
}

trap "die 'trap called'" SIGHUP SIGINT SIGTERM

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


# login information for your remote host, no quotes
login=seedit4me

# password information for your remote host, no quotes
pass=hTUq6aEYcJQ!

# host info for your remote host. include full URL standard format is sftp://ftp.servername.com
host=137.nl19.seedit4.me

#remote location where your finished downloads are on your seedbox
remote_dir=/home/seedit4me/torrents/rtorrent

#local directory where you are storing your downloads for further processing
local_dir=/media/localDownloads/syncthing

# The next few lines checks if lftp is running and stops the script if so.
# Will also show the PID if you want to kill the lftp from running manually (although you can use pkill lftp)

checkifrunning=$(ps -aux | grep [l]ftp | awk '{print $2}')
if [[ $checkifrunning ]]; then
  echo "Synctorrent is running already. PID " $checkifrunning
  exit 1
else
 
# Runs the lftp to sync, please amend xxxxx to your ssh / sftp port if required or remove the -p xxxxx option altogether if desired.
# command use-pget-n=20 uses 20 threads, command -P1 does one file at a time.
# Amend as needed keeping in mind not flooding your remote host with too many connections.
# command --log=lftp_logs.log will write to the log location you specify, for troubleshooting.  Remove if not needed.
 
  lftp -u $login,$pass $host -p 2105 << EOF
mirror --use-pget-n=20 -P1 -c --log=lftp_logs.log $remote_dir $local_dir
  quit
EOF
  exit 0
fi
