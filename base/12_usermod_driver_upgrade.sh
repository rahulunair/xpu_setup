#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

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
sudo apt-get update

colored_output "Reinstalling compute and media runtimes if anything is missing..." blue
apt-get install -y \
  intel-opencl-icd intel-level-zero-gpu level-zero \
  intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 \
  libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri \
  libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers \
  mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo hwinfo clinfo

colored_output "Installing development packages..." blue
apt-get install -y \
  libigc-dev intel-igc-cm libigdfcl-dev libigfxcmrt-dev level-zero-dev

colored_output "Upgrading packages..." blue
sudo apt-get -y upgrade
