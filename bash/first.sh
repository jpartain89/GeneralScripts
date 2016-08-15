#!/bin/bash
set -e

# First Step Script.
# Splits off between Linux/macOS to start

DIR=$(dirname "$(readlink -f "$0")")
GIT_DIR=/home/jpartain89/git

if [[ ! -e "$GIT_DIR" ]]; then
    mkdir "$GIT_DIR"
fi

allunix_clone ()
    {
        if [[ ! -e "$GIT_DIR/myfunctions" ]]; then
            git clone https://jpartain89@github.com/jpartain89/myfunctions.git "$GIT_DIR/myfunctions"
            source "$GIT_DIR/myfunctions/allunix"
        else
            source "$GIT_DIR/myfunctions/allunix"
        fi
    }

git-repos ()
    {
        # Git clones my "General Scripts" repo recursively with the submodule.
        if [[ ! -e "$GIT_DIR/generalscripts" ]]; then
            git clone --recursive https://jpartain89@github.com/jpartain89/generalscripts.git "$GIT_DIR/generalscripts"
        fi

        # Clones the git-map repo and then copys the program to the right spot
        if [[ ! -f /usr/local/bin/git-map ]]; then
            if [[ ! -e "$GIT_DIR/git-map" ]]; then
                git clone https://github.com/icefox/git-map.git "$GIT_DIR/git-map"
            fi
            sudo cp "$GIT_DIR/git-map/git-map" "/usr/local/bin/git-map"
            sudo chmod +x /usr/local/bin/git-map
        fi

        # Copys the conffiles directory that all my vm's use
        if [[ ! -e "$GIT_DIR/conffiles" ]]; then
            git clone https://jpartain89@github.com/jpartain89/conffiles.git "$GIT_DIR/conffiles"
        fi
    }

linux_dotfiles ()
    {
        if [[ ! -e "$GIT_DIR/linux_dotfiles" ]]; then
            git clone https://jpartain89@github.com/jpartain89/linux_dotfiles.git "$GIT_DIR/linux_dotfiles"
            source "$GIT_DIR/linux_dotfiles/bootstrap.sh"
        fi
    }

macOS-dotfiles ()
    {
        if [[ ! -e "$GIT_DIR/macOS_dotfiles" ]]; then
            git clone https://jpartain89@github.com/jpartain89/macos_dotfiles.git "$GIT_DIR/macos_dotfiles"
            source "$GIT_DIR/macos_dotfiles/bootstrap.sh"
    }

os_type ()
    {
        case $(uname -s) in
            Linux )
                echo ""
                echo "Looks like you're running linux."
                echo "Cloning linux_dotfiles and bootstrapping"
                linux-dotfiles;;
            Darwin )
                echo ""
                echo "Looks like you're running macOS."
                echo "Cloning macOS_dotfiles and bootstrapping"
                macOS-dotfiles;;
            * )
                echo ""
                echo "Not running Linux or macOS."
                echo "Exiting"
                echo ""
                exit 1
        esac
    }

allunix_clone && git_repos && os_type && main
