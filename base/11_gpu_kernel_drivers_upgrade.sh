#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

alias sudo='sudo -E'

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

if [[ $EUID -ne 0 ]]; then
   colored_output "This script must be run as root" red
   exit 1
fi

colored_output "Updating package lists..." blue
apt-get update

colored_output "Installing gpg-agent and wget..." blue
apt-get install -y gpg-agent wget

# we might not need this ?
colored_output "Adding the unified repository for Intel Data Center GPU Flex and Max Series production releases..." blue
wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy/production/2328 unified" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list

colored_output "Adding the unified repository for Intel Data Center GPU Flex and Max Series rolling stable releases..." blue
wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy unified" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list

colored_output "Updating package lists..." blue
apt-get update

colored_output "Installing Intel i915 DKMS and XPU SMI..." blue
apt-get install -y intel-i915-dkms xpu-smi

# Reboot the system
colored_output "Rebooting the system..." blue
reboot -h now
