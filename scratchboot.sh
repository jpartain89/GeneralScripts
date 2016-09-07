#!/bin/bash
set -e

# My gist for downloading and spinning up a machine from as scratch
# as possible.

JP_GIT=https://jpartain89@github.com/jpartain89

if [[ $(uname -s) == 'Darwin' ]]; then
    echo ""
    echo "You're running this on macOS."
    echo "Now downloading the macOS first.sh script"
    echo "and running it."
    echo ""
    wget -O - https://raw.githubusercontent.com/jpartain89/macos_dotfiles/master/first.sh | bash
else
    GIT_DIR=/home/$USER/git
    OWNER=jpartain89:jpartain89
    allunix_clone; git_repos; linux_dotfiles;
    unset JP_GIT GIT_DIR OWNER allunix_clone git_repos linux_dotfiles
fi

allunix_clone ()
    {
        if [[ ! -e "$GIT_DIR" ]]; then
            echo ""
            echo "Looks like the generic ./git directory doesn't exist."
            echo "Creating now..."
            mkdir "$GIT_DIR"
        fi

        if [[ ! -e "$GIT_DIR/myfunctions" ]]; then
            echo ""
            echo "Cloning the 'myfunctions' repo"
            echo ""
            git clone "$JP_GIT/myfunctions.git" "$GIT_DIR/myfunctions"
        else
            echo ""
            echo "MyFunctions repo already present, sourcing allunix"
            echo ""
        fi
        echo ""
        echo "Changing ownership of myfunctions library."
        echo ""
        chown -R "$OWNER" "$GIT_DIR/myfunctions"
        export ALLUNIX="$GIT_DIR/myfunctions/allunix" &&
        source "$ALLUNIX"
    }

git_repos ()
    {
        # Git clones my "General Scripts" repo
        if [[ ! -e "$GIT_DIR/generalscripts" ]]; then
            echo ""
            echo "Cloning GeneralScripts repo"
            echo ""
            press_enter
            git clone "$JP_GIT/generalscripts.git" "$GIT_DIR/generalscripts"
            echo ""
            echo "Changing ownership of generalscripts directory."
            echo ""
            press_enter
            chown -R "$OWNER" "$GIT_DIR/generalscripts"
            if [[ ! -f /usr/local/bin/map-pull-sub ]]; then
                echo ""
                echo "Copying map-pull-sub over to /usr/local/bin"
                echo ""
                press_enter
                sudo ln -s "$GIT_DIR/generalscripts/bash/map-pull-sub" /usr/local/bin/map-pull-sub
                chmod +x /usr/local/bin/map-pull-sub
            else
                echo ""
                echo "map-pull-sub already installed."
                echo "Continuing."
                echo ""
                press_enter
            fi
        else
            echo ""
            echo "General Scripts repo already cloned."
            echo "Moving on."
            echo ""
            press_enter
        fi

        # Clones the git-map repo and then copys the program to the right spot
        if [[ ! -f /usr/local/bin/git-map ]]; then
            if [[ ! -e "$GIT_DIR/git-map" ]]; then
                echo ""
                echo "Cloning git-map repo"
                echo ""
                press_enter
                git clone https://github.com/icefox/git-map.git "$GIT_DIR/git-map"
                echo ""
                echo "Changing ownership of git-map repo"
                echo ""
                press_enter
                chown -R "$OWNER" "$GIT_DIR/git-map"
            else
                echo ""
                echo "git-map already cloned. Moving on"
                echo ""
                press_enter
            fi
            echo ""
            echo "Linking git-map to /usr/local/bin"
            echo ""
            press_enter
            sudo ln -s "$GIT_DIR/git-map/git-map" "/usr/local/bin/git-map"
            sudo chmod +x /usr/local/bin/git-map
        fi

        # Copys the conffiles directory that all my vm's use
        # Also including on macOS machines for editing and continuity
        if [[ ! -e "$GIT_DIR/conffiles" ]]; then
            echo ""
            echo "cloning conffiles. "
            echo ""
            press_enter
            git clone "$JP_GIT/conffiles.git" "$GIT_DIR/conffiles"
            echo ""
            echo "Changing ownership of conffiles."
            echo ""
            press_enter
            sudo chown -R "$OWNER" "$GIT_DIR/conffiles"
        else
            echo ""
            echo "conffiles already cloned. Moving On."
            echo ""
            press_enter
        fi
    }

linux_dotfiles ()
    {
        if [[ ! -e "$GIT_DIR/linux_dotfiles" ]]; then
            echo ""
            echo "Cloning linux_dotfiles."
            echo ""
            press_enter
            git clone "$JP_GIT/linux_dotfiles.git" "$GIT_DIR/linux_dotfiles"
            echo ""
            echo "Changing ownership of linux_dotfiles"
            echo ""
            press_enter
            sudo chown -R "$OWNER" "$GIT_DIR/linux_dotfiles"
        else
            echo ""
            echo "linux_dotfiles already cloned."
            echo ""
        fi
        echo ""
        echo "Sourcing bootstrap.sh"
        echo ""
        press_enter
        source "$GIT_DIR/linux_dotfiles/bootstrap.sh"
        exit 0
    }

macOS_dotfiles ()
    {
        if [[ ! -e "$GIT_DIR/macos_dotfiles" ]]; then
            echo ""
            echo "Cloning macOS Dotfiles"
            echo ""
            press_enter
            git clone "$JP_GIT/macos_dotfiles.git" "$GIT_DIR/macos_dotfiles"
            echo ""
            echo "Changing Ownership of macOS Dotfiles."
            echo ""
            press_enter
            chown -R "$OWNER" "$GIT_DIR/macos_dotfiles"
        else
            echo ""
            echo "macos_dotfiles repo already cloned."
            echo ""
        fi
        echo ""
        echo "Now sourcing the bootstrap.sh file"
        echo ""
        press_enter
        source "$GIT_DIR/macos_dotfiles/bootstrap.sh"
        exit 0
    }
