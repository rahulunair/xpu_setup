#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"
set -e

KERNEL_VERSION="5.15.0-73"
REPO_URL="https://repositories.intel.com/graphics"
REPO_KEY_URL="${REPO_URL}/intel-graphics.key"
REPO_LIST_FILE="/etc/apt/sources.list.d/intel.gpu.jammy.list"

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

# Check kernel version
colored_output "Checking kernel version..." blue
if [[ "$(uname -r)" != "${KERNEL_VERSION}-generic" ]]; then
    colored_output "Error: Incorrect kernel version. Please run setup_kernel.sh first." red
    exit 1
fi

# Add package repository
colored_output "Adding package repository..." blue
sudo apt-get install -y gpg-agent wget
wget -qO - "${REPO_KEY_URL}" | \
  sudo gpg --dearmor | sudo sh -c "cat > /usr/share/keyrings/intel-graphics.gpg"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy max" | \
  sudo tee "${REPO_LIST_FILE}"

# Install dependencies
colored_output "Installing dependencies..." blue
sudo apt-get update
sudo apt-get -y install \
    gawk \
    dkms \
    linux-headers-$(uname -r) \
    libc6-dev

# Install DKMS kernel modules
# https://dgpu-docs.intel.com/driver/installation.html#ubuntu-server
# package names for dkms drivers changed, updated with latest one
colored_output "Installing DKMS kernel modules..." blue
#sudo apt-get install -y intel-platform-vsec-dkms intel-platform-cse-dkms
#sudo apt-get install -y intel-i915-dkms intel-fw-gpu
sudo apt-get install -y intel-i915-dkms

# Install run-time packages
colored_output "Installing run-time packages..." blue
sudo apt-get install -y \
  intel-opencl-icd intel-level-zero-gpu level-zero \
  intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
  libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri \
  libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers \
  mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo

# OPTIONAL: Install developer packages
colored_output "Installing developer packages..." blue
sudo apt-get install -y \
  libigc-dev \
  intel-igc-cm \
  libigdfcl-dev \
  libigfxcmrt-dev \
  level-zero-dev \
  libdrm-dev

# Reboot
if [ -z "$OMMIT_REBOOT" ]
then
    colored_output "Rebooting the system in 10 seconds..." blue
    sleep 10
    sudo reboot
fi