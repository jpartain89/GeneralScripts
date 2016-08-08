#!/bin/bash

# RapidLoop Agent Install - Installs Repo, updates, and runs the installer



echo "deb http://packages.rapidloop.com/debian stable main" | sudo tee /etc/apt/sources.list.d/rapidloop.list
apt-key adv --keyserver pgp.mit.edu --recv-keys 1E1BACF5
