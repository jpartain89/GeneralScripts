#!/bin/bash -e

# First Step Script.
# Splits off between Linux/macOS to start

if [[ $(uname -s) == 'Darwin' ]]; then
    git_dir=/Users/$(logname)/git
    owner=jpartain89:staff
else
    git_dir=/home/$(logname)/git
    owner=jpartain89:jpartain89
fi

jp_git=https://jpartain89@github.com/jpartain89

if [[ ! -e "$git_dir" ]]; then
    echo ""
    echo "Looks like the generic ./git directory doesn't exist."
    echo "Creating now..."
    press_enter
    mkdir "$git_dir"
fi

if [[ ! -e "$git_dir/myfunctions" ]]; then
    echo ""
    echo "Cloning the myfunctions repo"
    echo ""
    git clone "$jp_git/myfunctions.git" "$git_dir/myfunctions"
    chown -R "$owner" "$git_dir/myfunctions"
fi

. "$allunix"

git_repos ()
    {
        # Git clones my "General Scripts" repo
        if [[ ! -e "$git_dir/generalscripts" ]]; then
            echo ""
            echo "Cloning GeneralScripts repo"
            echo ""
            press_enter
            git clone "$jp_git/generalscripts.git" "$git_dir/generalscripts"
            echo ""
            echo "Changing ownership of generalscripts directory."
            echo ""
            press_enter
            chown -R "$owner" "$git_dir/generalscripts"
            if [[ ! -f /usr/local/bin/map-pull-sub ]]; then
                echo ""
                echo "Copying map-pull-sub over to /usr/local/bin"
                echo ""
                press_enter
                sudo ln -s "$git_dir/generalscripts/bash/map-pull-sub" /usr/local/bin/map-pull-sub
                chmod +x /usr/local/bin/map-pull-sub
            fi
        else
            echo ""
            echo "General Scripts repo already cloned."
            echo "Moving on."
            echo ""
            press_enter
        fi

        # Clones the git-map repo and then copy the program to the right spot
        if [[ ! -f /usr/local/bin/git-map ]]; then
            if [[ ! -e "$git_dir/git-map" ]]; then
                echo ""
                echo "Cloning git-map repo"
                echo ""
                press_enter
                git clone https://github.com/icefox/git-map.git "$git_dir/git-map"
                echo ""
                echo "Changing ownership of git-map repo"
                echo ""
                press_enter
                chown -R "$owner" "$git_dir/git-map"
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
            sudo ln -s "$git_dir/git-map/git-map" "/usr/local/bin/git-map"
            sudo chmod +x /usr/local/bin/git-map
        fi

        # Copys the conffiles directory that all my vm's use
        if [[ ! -e "$git_dir/conffiles" ]]; then
            echo ""
            echo "cloning conffiles. "
            echo ""
            press_enter
            git clone "$jp_git/conffiles.git" "$git_dir/conffiles"
            echo ""
            echo "Changing ownership of conffiles."
            echo ""
            press_enter
            sudo chown -R "$owner" "$git_dir/conffiles"
        else
            echo ""
            echo "conffiles already cloned. Moving On."
            echo ""
            press_enter
        fi
    }

linux_dotfiles ()
    {
        if [[ ! -e "$git_dir/linux_dotfiles" ]]; then
            git clone "$jp_git/linux_dotfiles.git" "$git_dir/linux_dotfiles"
            source "$git_dir/linux_dotfiles/bootstrap.sh"
            sudo chown -R "$owner" "$git_dir/linux_dotfiles"
        else
            echo ""
            echo "linux_dotfiles already cloned."
            echo "Sourcing bootstrap.sh"
            echo ""
            press_enter
            . "$git_dir/linux_dotfiles/bootstrap.sh"
            exit 0
        fi
    }

macOS_dotfiles ()
    {
        if [[ ! -e "$git_dir/macos_dotfiles" ]]; then
            echo ""
            echo "Cloning macOS Dotfiles"
            echo ""
            press_enter
            git clone "$jp_git/macos_dotfiles.git" "$git_dir/macos_dotfiles"
            echo ""
            echo "Now sourcing the bootstrap.sh file"
            echo ""
            press_enter
            . "$git_dir/macos_dotfiles/bootstrap.sh"
            echo ""
            echo "Changing Ownership of macOS Dotfiles."
            echo ""
            press_enter
            chown -R "$owner" "$git_dir/macos_dotfiles"
        fi
    }

os_type ()
    {
        case $(uname -s) in
            Linux )
                echo ""
                echo "Looks like you're running linux."
                echo "Cloning linux_dotfiles and bootstrapping"
                echo ""
                press_enter
                linux_dotfiles;;
            Darwin )
                echo ""
                echo "Looks like you're running macOS."
                echo "Cloning macOS_dotfiles and bootstrapping"
                echo ""
                press_enter
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
