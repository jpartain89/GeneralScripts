#!/bin/bash -e

# This script is meant to be downloaded on a new macOS device, either
# bought new or freshly reinstalled.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

USER="${USER}"
GITHUB_WEB="https://jpartain89@github.com/jpartain89"
GITHUB_SSH="git@github.com:jpartain89"
GITLAB_SSH="git@gitlab.com:jpartain89"
GPG_KEY="AA90C7B4"
GIT_LOC="$HOME/git"
GITHUB_REPO=(
    brewdate
    generalscripts
    git-automap
    git-autopull
    software-install-guides
)
GITLAB_REPO=(
    conffiles
    dotfiles
    generalscripts
    nginx-deployment
)
BREW_FIRST=(
    git
    nano
    curl
    htop
)
ansible_github_REPOS=(
    ansible-role-monit-from-source
    ansible-role-ddclient
    ansible-role-install-nginx
    ansible-role-logrotate
    ansible-role
    ansible-run-updates
    ansible-role-monit-binaries
    ansible-ubuntu-server
    ansible-role-virtualbox
    personal_ansible_plays
    ansible-role-configure-monit
    ansible-macOS-Setup
)
ansible_gitlab_REPOS=(
    ansible-raspberry-pi-startup
    ansible-vars
)
GIT_CONFIGS=(
    "core.excludesfile ~/.gitignore"
    "core.editor nano"
    "core.whitespace 'fix,-indent-with-non-tab,trailing-space'"
    "github.token token"
    "github.user jpartain89"
    "web.browser firefox"
    "color.ui auto"
    "credential.helper osxkeychain"
    "color.diff.frag 'magenta bold'"
    "color.diff.new 'green bold'"
    "color.diff.meta 'yellow reverse'"
    "color.diff.old 'red bold'"
    "color.diff.whitespace 'red reverse'"
    "web.browser firefox"
    "color.branch.current 'yellow reverse'"
    "color.branch.local 'green bold'"
    "color.branch.remote 'cyan bold'"
    "gui.tabsize 4"
    "gui.fontui '-family \"San Francisco Display\" -size 13 -weight normal -slant roman -underline 0 -overstrike 0'"
    "color.status.untracked 'red bold'"
    "color.status.added 'green bold'"
    "color.status.changed 'yellow reverse'"
    "user.signingkey AA90C7B4"
    "user.name 'Justin Partain'"
    "user.email jpartain89@gmail.com"
    "filter.lfs.required true"
    "filter.lfs.clean 'git-lfs clean -- %f'"
    "filter.lfs.smudge 'git-lfs smudge -- %f'"
    "filter.lfs.process 'git-lfs filter-process'"
)

prompt() {
    if [[ -z "${CI}" ]]; then
        read -pr "Hit Enter to ${1}"
    fi
}

prompt "First, we install xcode's stuff"
xcode-select --install &&

prompt "Next, we install HomeBrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&

prompt "We now install a few homebrew items."
brew install "${BREW_FIRST[@]}" &&

Prompt "We work on cloning your basic git repos"
mkdir -p "$GIT_LOC" &&
for i in "${GITHUB_REPO[@]}"; do
    git clone "${GITHUB_SSH}/${i}" "${GIT_LOC}/${i}" --recurse-submodules
done

for i in "${GITLAB_REPO[@]}"; do
    git clone "${GITLAB_SSH}/${i}" "${GIT_LOC}/${i}" --recurse-submodules
done

git clone https://github.com/scopatz/nanorc.git "${GIT_LOC}/nanorc" --recurse-submodules
git clone git@gitlab.com:dallas-universal-life-church/nginx-deployment.git "${GIT_LOC}/dulc_nginx" --recurse-submodules
git clone git@gitlab.com:dallas-universal-life-church/wiki.git "${GIT_LOC}/Wiki" --recurse-submodules

prompt "Installing dotfiles"
sudo -u $USER bash "${GIT_LOC}/dotfiles/linking"

prompt "Installing NanoRC Files"
sudo -u $USER bash "${GIT_LOC}/nanorc/install.sh"

prompt "Installing git-autopull and brewdate"
for i in brewdate git-autopull; do
    sudo -u $USER bash "${GIT_LOC}/${i}/${i}"
done

ANSIBLE() {
    mkdir -p "${GIT_LOC}/ansibleParent"
    for i in "${ansible_github_REPOS[@]}"; do
        git clone "${GITHUB_SSH}/${i}" "${GIT_LOC}/ansibleParent/${i}" --recurse-submodules
    done
    for i in "${ansible_gitlab_REPOS[@]}"; do
        git clone "${GITLAB_SSH}/${i}" "${GIT_LOC}/ansibleParent/${i}" --recurse-submodules
    done

    sudo -H pip install -U ansible
}

read -rp ansible "You want ansible on this machine?"

case "$ansible" in
    y | Y ) ANSIBLE;;
    yes | YES | Yes ) ANSIBLE;;
    n | N ) Continue;;
    no | NO | No ) Continue;;
    * ) Continue;;
esac

prompt "Now running .macOS config files"
sudo "${GIT_LOC}/dotfiles/.macos"

prompt "Installing brew-file"
brew install rcmdnk/file/brew-file &&

read -rp "What is this machine's brew-file name" BREW_FILE_NAME
prompt "Setting brew-file's repo"
brew-file set_repo "jpartain89/brewfile-marks_imac" &&

echo "Now we run brew-file install, which tends to take a while and"
echo "can be hinky. Good Luck"
brew-file install
