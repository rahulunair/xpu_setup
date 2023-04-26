#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"
set -e

sudo sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
sudo apt update &&\
  sudo apt upgrade -y

sudo apt install -y wget curl git coreutils gpg-agent 
