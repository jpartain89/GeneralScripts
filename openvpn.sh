#!/bin/bash

# My personal OpenVPN installation script.

# This will make the current directory, aka the directory this
# specific script was called from as what $DIR will output.
DIR="$( cd "$( dirname "$0" )" && pwd )"
export DIR
yes_sudo

main ()
    {
        dpkg -l | grep openvpn &> /dev/null
        if [[ $? != 0 ]]; then
            echo ""
            echo "Looks like OpenVPN is not installed in your system!"
            echo "This means it will get installed, then we'll double check to see if "
            echo "any prior-, pre-, or leftover-installed configs are around as best we can."
            echo ""
            echo ""
            press_enter
            apt-get update && apt-get install openvpn -y
            press_enter
        else
            echo ""
            echo "Looks like OpenVPN is already installed."
            press_enter
        fi
        echo ""
        echo "Next, I'm going to first search in your home directory, then"
        echo "download the PIA OpenVPN Profiles."
        echo "If these files are already in your home directory, the download will skip"
        if [[ ! -d ~/openvpn ]]; then
            if [[ ! -e ~/openvpn.zip ]]; then
                echo ""
                echo "Looks like no zip file or folder in your home directory for PIA's files."
                echo "Now we will get those downloaded and unzipped."
                wget -P ~/ https://www.privateinternetaccess.com/openvpn/openvpn.zip
            else
                echo ""
                echo "Looks like openvpn.zip is already downloaded. Moving on."
            fi
            echo ""
            echo "Next, unzipping openvpn.zip, after making sure unzip is installed."
            dpkg -l | grep unzip &> /dev/null
            if [[ $? != 0 ]]; then
                apt-get install unzip
            fi
            unzip openvpn.zip -d ~/openvpn
            cp ~/openvpn/*.crt /etc/openvpn/
            cp ~/openvpn/*.pem /etc/openvpn/
            clear
            echo ""
            echo "These are the .ovpn files in the PIA OpenVPN directory."
            echo "Please, select one to continue."
            echo "BTW, this will copy that file over to /etc/openvpn/ and change .ovpn to .conf"
            PS3="Use number to select a file or 'stop' to cancel: "
            select pia_file in ~/openvpn/*.ovpn
            do
                if [[ "$REPLY" == stop ]]; then break; fi

    }
