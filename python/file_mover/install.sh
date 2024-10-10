#!/bin/bash

# Installer script for the file mover program
CONFIG_FILE="config.yml"
LOG_DIR="logs"
PYTHON_REQUIREMENTS="requirements.txt"

# Check if Python3 is installed
if ! command -v python3 &> /dev/null
then
    echo "Python3 could not be found. Please install Python3."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null
then
    echo "pip3 could not be found. Installing pip3..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r $PYTHON_REQUIREMENTS

# Create the config.yml file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating default config.yml..."

    cat <<EOL > $CONFIG_FILE
directories:
  FROM: '/media/Downloads/syncthing'   # Source directory where files are downloaded
  TO: '/media/Porn'                    # Target directory where videos will be organized by studio

studio_mappings:
  "Club Inferno": 
    - "Club Inferno"
    - "Powerhole"
  "MEN": 
    - "[MEN]"
    - "Drill My Hole"
    - "Stepdick"
  "Treasure Island Media": 
    - "Treasure Island Media"
    - "Fucking Crazy"
  "RawFuckClub": 
    - "RFC"
    - "RawFuckClub"
EOL
    echo "config.yml created."
else
    echo "config.yml already exists. Skipping creation."
fi

# Create the logs directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
    mkdir $LOG_DIR
    echo "Log directory created at $LOG_DIR."
else
    echo "Log directory already exists."
fi

# Make Python program executable
if [ -f "file_mover.py" ]; then
    chmod +x file_mover.py
    echo "file_mover.py is now executable."
else
    echo "file_mover.py not found. Please ensure the script is in this directory."
fi

echo "Installation complete. You can now run the program using './file_mover.py'"
