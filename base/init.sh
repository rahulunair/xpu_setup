#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"
set -e

sudo apt update &&\
  sudo apt upgrade -y

sudo apt install wget curl git coreutils gpg-agent 
