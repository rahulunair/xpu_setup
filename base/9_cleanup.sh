#!/bin/bash
#
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"
set -e

sudo apt update &&\
  sudo apt upgrade -y &&\
  sudo apt autoremove
