#!/bin/bash
set -e

# script to install domotz onto debian machines.

wget https://portal.domotz.com/download/agent_packages/domotz-box-x64.deb
sudo dpkg -i domotz-box-x64.deb
