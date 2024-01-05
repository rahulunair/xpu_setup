#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"
set -e

# Check if OS is Ubuntu 22.04
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$NAME" != "Ubuntu" ] || [ "$VERSION_ID" != "22.04" ]; then
        echo "This script is only intended to run on Ubuntu 22.04."
        exit 1
    fi
else
    echo "Cannot identify the OS."
    exit 1
fi

sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sudo apt update &&\
  sudo apt upgrade -y
sudo apt install -y wget curl git coreutils gpg-agent
