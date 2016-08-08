#!/bin/bash

# RapidLoop Agent Install - Installs Repo, updates, and runs the installer

DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/myfunctions/allunix.sh

yes_sudo

echo "deb http://packages.rapidloop.com/debian stable main" | tee /etc/apt/sources.list.d/rapidloop.list

apt-key adv --keyserver pgp.mit.edu --recv-keys 1E1BACF5

apt-get update && apt-get install opsdash-agent

echo ""
echo "The agent should have installed correctly."
echo "Now, after pressing enter, nano will open to the agent config file"
echo "For you to look over and setup."
press_enter
nano /etc/opsdash/agent.cfg
echo ""
echo "Now starting the agent service."
press_enter
service opsdash-agentd start
