#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

REPO_URL="https://repositories.intel.com/gpu/ubuntu"
REPO_KEY_URL="${REPO_URL}/intel-graphics.key"
REPO_LIST_FILE="/etc/apt/sources.list.d/intel-gpu-jammy.list"

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

exit_on_error() {
    local exit_code=$1
    local message=$2
    if [ $exit_code -ne 0 ]; then
        colored_output "$message" red
        exit $exit_code
    fi
}

if [[ $EUID -ne 0 ]]; then
   colored_output "This script must be run as root" red
   exit 1
fi

colored_output "Updating package lists..." blue
apt-get update
exit_on_error $? "Failed to update package lists."

colored_output "Installing gpg-agent and wget..." blue
apt-get install -y gpg-agent wget
exit_on_error $? "Failed to install gpg-agent and wget."

# Remove existing sources list and keys for GPU drivers if they exist
rm -f /etc/apt/sources.list.d/intel-gpu-jammy.list
rm -f /usr/share/keyrings/intel-graphics.gpg



# Attempt to add the GPG key
wget -qO - "${REPO_KEY_URL}" | gpg --dearmor -o /usr/share/keyrings/intel-graphics.gpg && \
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] ${REPO_URL} jammy unified" | tee "${REPO_LIST_FILE}"

if [ $? -ne 0 ]; then
    colored_output "Failed to add GPG key, trusting repo without key..." yellow
    echo "deb [arch=amd64 trusted=yes] ${REPO_URL} jammy unified" | tee "${REPO_LIST_FILE}"
fi

colored_output "Updating package lists..." blue
apt-get update
exit_on_error $? "Failed to update package lists after adding repo."

apt-mark unhold $(apt-mark showhold)
colored_output "Installing Intel GPU FW, i915 DKMS and XPU SMI..." blue
apt-get install -y intel-i915-dkms xpu-smi intel-fw-gpu
exit_on_error $? "Failed to install Intel i915 DKMS and XPU SMI."
apt-mark hold intel-i915-dkms xpu-smi intel-fw-gpu

colored_output "Please reboot the system..." blue
# Uncomment the following line to enable automatic reboot
# reboot -h now
