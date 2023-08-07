#!/bin/bash

# Set environment variables
export DEBIAN_FRONTEND=noninteractive

# Alias sudo to keep environment variables
alias sudo='sudo -E'

# Function for colored output
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

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   colored_output "This script must be run as root" red
   exit 1
fi

# Update package lists
colored_output "Updating package lists..." blue
apt-get update

# Install compute and media runtimes
colored_output "Installing compute and media runtimes..." blue
apt-get install -y \
  intel-opencl-icd intel-level-zero-gpu level-zero \
  intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
  libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri \
  libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers \
  mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo hwinfo clinfo

# Install development packages
colored_output "Installing development packages..." blue
apt-get install -y \
  libigc-dev intel-igc-cm libigdfcl-dev libigfxcmrt-dev level-zero-dev
