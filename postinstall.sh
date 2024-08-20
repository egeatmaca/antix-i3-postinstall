#!/bin/bash

# Cd into script directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd $SCRIPT_DIR

# Define constants
PACKAGES=packages.txt
KEYRING_FILE=antix-archive-keyring_20019.5.0_all.deb
KEYRING_URL=http://repo.antixlinux.com/buster/pool/main/a/antix-archive-keyring/$KEYRING_FILE

# Update AntiX archive keyring
wget $KEYRING_URL
sudo apt install ./$KEYRING_FILE
rm $KEYRING_FILE

# Add additional gpg keys and apt repositories
## VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
## Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Update packages
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Install packages
while read package; do
  sudo apt-get install -y "$package"
done <./$PACKAGES

# Copy dotfiles
sudo cp -a ./dotfiles/root/. /
cp -a ./dotfiles/user/. ~
