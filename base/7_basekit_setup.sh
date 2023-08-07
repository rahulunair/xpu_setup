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
    wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
    sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
    sudo rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
    echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
    sudo apt update
}

# added full basekit, hpckit and renderkit as well.
install_packages() {
    colored_output "Installing Intel Base Kit packages..." blue
    sudo apt-get install -y \
        intel-oneapi-common-vars \
        intel-oneapi-common-licensing \
        intel-oneapi-dpcpp-ct \
        intel-oneapi-dev-utilities \
        intel-oneapi-dpcpp-debugger \
        intel-oneapi-libdpstd-devel \
        intel-oneapi-diagnostics-utility \
        intel-oneapi-tbb-devel \
        intel-oneapi-ccl-devel \
        intel-oneapi-compiler-dpcpp-cpp \
        intel-oneapi-ipp-devel \
        intel-oneapi-ippcp-devel \
        intel-oneapi-mkl-devel \
        intel-basekit \
        intel-hpckit \
        intel-renderkit
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    colored_output "Updating package index..." blue
    sudo apt-get update
    add_intel_repository
    install_packages
    colored_output "Installation completed!" green
fi

