#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

alias sudo="sudo -E"
colored_output() {
    local text="$1"
    local color="$2"

    case "${color}" in
        red)    echo -e "\033[31m${text}\033[0m" ;;
        green)  echo -e "\033[32m${text}\033[0m" ;;
        yellow) echo -e "\033[33m${text}\033[0m" ;;
        blue)   echo -e "\033[34m${text}\033[0m" ;;
        *)      echo "${text}" ;;
    esac
}

sudo apt update &&\
  sudo apt upgrade -y &&\
  sudo apt autoremove

# Reboot
colored_output "Rebooting the system in 10 seconds..." blue
sleep 10
sudo reboot
