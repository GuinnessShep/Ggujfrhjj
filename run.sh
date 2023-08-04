#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." 1>&2
    exit 1
fi

# Detect and print Kernel & Ubuntu versions
UBUNTU_VERSION=$(lsb_release -rs)
KERNEL_VERSION=$(uname -r)
echo "Ubuntu Version: $UBUNTU_VERSION"
echo "Kernel Version: $KERNEL_VERSION"

# Backup existing sources.list and replace with a default one
echo "Backing up and replacing sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.backup
echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-security main restricted universe multiverse" >> /etc/apt/sources.list

# Remove potential lock files
echo "Removing lock files..."
rm -f /var/lib/dpkg/lock*
rm -f /var/lib/apt/lists/lock*
rm -f /var/cache/apt/archives/lock*

# Fix broken dependencies
echo "Fixing broken dependencies..."
apt --fix-broken install -y

# Forcefully reconfigure dpkg database
echo "Forcefully reconfiguring dpkg database..."
dpkg --configure -a --force-all

# Clear held packages
echo "Clearing held packages..."
apt-mark unhold *

# Update and upgrade
echo "Updating and upgrading packages..."
apt update && apt upgrade -y

# Reinstall potentially corrupt packages
echo "Reinstalling potentially corrupt packages..."
dpkg -l | grep "^rc" | cut -d " " -f 3 | xargs sudo apt-get --purge remove
apt-get install --reinstall $(dpkg -l | grep '^ii' | awk '{print $2}')

# Clean cache
echo "Cleaning cache..."
apt clean && apt autoclean

# Reset apt cache
echo "Resetting apt cache..."
rm -rf /var/lib/apt/lists/*
apt update

# Fix unmet dependencies
echo "Fixing unmet dependencies..."
apt --fix-missing update
apt --fix-missing upgrade -y

# Force all upgrades (even if they break something)
echo "Forcefully upgrading all packages..."
apt-get dist-upgrade --force-yes -y

# Final cleanup
echo "Final cleanup..."
apt autoremove -y
apt clean

echo "Process completed."
echo "IMPORTANT: This script has taken forceful measures. Please review the changes and test your system thoroughly. Manual intervention might still be required in some cases. Always have backups before running maintenance scripts like this."
