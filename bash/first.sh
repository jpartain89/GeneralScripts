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
            echo ""
            echo "Cloning the 'myfunctions' repo"
            echo ""
            git clone https://jpartain89@github.com/jpartain89/myfunctions.git "$GIT_DIR/myfunctions" && 
            source "$GIT_DIR/myfunctions/allunix"
        else
            echo ""
            echo "MyFunctions repo already present, sourcing allunix"
            echo ""
            source "$GIT_DIR/myfunctions/allunix"
        fi
    }

git_repos ()
    {
        # Git clones my "General Scripts" repo recursively with the submodule.
        if [[ ! -e "$GIT_DIR/generalscripts" ]]; then
            echo ""
            echo "Cloning GeneralScripts repo"
            echo ""
            git clone --recursive https://jpartain89@github.com/jpartain89/generalscripts.git "$GIT_DIR/generalscripts"
            if [[ ! -f /usr/local/bin/map-pull-sub ]]; then
                echo ""
                echo "Copying map-pull-sub over to /usr/local/bin"
                echo ""
                cp "$GIT_DIR/generalscripts/bash/map-pull-sub" /usr/local/bin/map-pull-sub
                chmod +x /usr/local/bin/map-pull-sub
            fi
        fi

        # Clones the git-map repo and then copys the program to the right spot
        if [[ ! -f /usr/local/bin/git-map ]]; then
            if [[ ! -e "$GIT_DIR/git-map" ]]; then
                echo ""
                echo "Cloning git-map repo"
                echo ""
                git clone https://github.com/icefox/git-map.git "$GIT_DIR/git-map"
            fi
            echo ""
            echo "Copying git-map to /usr/local/bin"
            echo ""
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
        else
            echo ""
            echo "linux_dotfiles already cloned. Exiting..."
            echo ""
            exit 0
        fi
    }

macOS_dotfiles ()
    {
        if [[ ! -e "$GIT_DIR/macOS_dotfiles" ]]; then
            git clone https://jpartain89@github.com/jpartain89/macos_dotfiles.git "$GIT_DIR/macos_dotfiles"
            source "$GIT_DIR/macos_dotfiles/bootstrap.sh"
        fi
    }

os_type ()
    {
        case $(uname -s) in
            Linux )
                echo ""
                echo "Looks like you're running linux."
                echo "Cloning linux_dotfiles and bootstrapping"
                linux_dotfiles;;
            Darwin )
                echo ""
                echo "Looks like you're running macOS."
                echo "Cloning macOS_dotfiles and bootstrapping"
                macOS_dotfiles;;
            * )
                echo ""
                echo "Not running Linux or macOS."
                echo "Exiting"
                echo ""
                exit 1
        esac
    }

allunix_clone && git_repos && os_type
