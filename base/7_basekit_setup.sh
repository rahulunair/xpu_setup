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

add_intel_repository() {
    colored_output "Adding Intel oneAPI repository..." blue
    wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
    sudo apt update
}


# added full basekit, hpckit, aikit and renderkit as well.
install_packages() {
    colored_output "Installing Intel Base Kit packages..." blue
    sudo apt-get install -y \
        intel-basekit \
        intel-hpckit \
        intel-aikit \
        intel-renderkit
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    colored_output "Updating package index..." blue
    sudo apt-get update
    add_intel_repository
    install_packages
    colored_output "Installation completed!" green
fi

