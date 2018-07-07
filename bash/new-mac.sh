#!/bin/bash -e

echo "First, we install xcode's stuff"
xcode-select --install &&
echo "Next, we install HomeBrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
echo "Installing brew-file"
brew install rcmdnk/file/brew-file &&
brew-file set_repo jpartain89/brewfile-macbook &&
echo "This next step will most likely take FOREVER,"
echo "Plus, you'll most likely have to stop it and restart"
echo "a few times. So, sadly, this is where the script ends for now."
brew-file install
