#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"

colored_output() {
    text=$1
    color=$2
    case $color in
        red) echo -e "\033[31m${text}\033[0m" ;;
        green) echo -e "\033[32m${text}\033[0m" ;;
        blue) echo -e "\033[34m${text}\033[0m" ;;
        yellow) echo -e "\033[33m${text}\033[0m" ;;
        *) echo "${text}" ;;
    esac
}

install_packages() {
    colored_output "Installing Intel HPC Kit..." blue
    sudo sudo apt install intel-hpckit -y
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    colored_output "Updating package index..." blue
    sudo apt update
    install_packages
    colored_output "Installation completed!" green
fi

