#!/bin/bash

# upgrade kernel to latest 5.15 version and userspace apps

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
CURRENT_KERNEL=$(uname -r)


# unhold held out package
apt-mark unhold $(apt-mark showhold)

# add proposed jammy repo - to get the latest patches
echo "deb http://archive.ubuntu.com/ubuntu/ jammy-proposed restricted main multiverse universe" | sudo tee /etc/apt/sources.list.d/ubuntu-jammy-proposed.list

colored_output "Updating package lists..." blue
apt-get update

colored_output "Upgrading packages..." blue
apt-get upgrade -y

# Find the latest 5.15.x version of the kernel
colored_output "Finding the latest 5.15.x version of the kernel..." blue
KERNEL_VERSION=$(apt-cache madison linux-image-generic | awk '/5\.15\./{print $3}' | awk -F '[.-]' '{print $1"."$2"."$3"-"$4}' | sort --version-sort --reverse | head -n 1)
colored_output "Latest 5.15.x kernel version found: ${KERNEL_VERSION}" green

# Install the specific kernel version
colored_output "Installing the specific kernel version..." blue
apt-get install -y --install-suggests "linux-image-${KERNEL_VERSION}-generic"
apt-get install -y  "linux-headers-${KERNEL_VERSION}-generic"
apt-get install -y "linux-modules-extra-${KERNEL_VERSION}-generic"

colored_output "Updating grub..." blue
update-grub

colored_output "Setting the default kernel..." blue
#sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux '${CURRENT_KERNEL}-generic'"/g' /etc/default/grub
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/g' /etc/default/grub

colored_output "Updating grub again..." blue
update-grub

# unhold packages related to gpu after upgrading kernel
# sudo apt-mark unhold intel-igc-cm intel-gsc libmetee libmetee-dev intel-media-va-driver-non-free \
#   libmfx1 libmfx-tools libigfxcmrt7 libmfxgen1 libvpl2 libvpl-tools libmfx-dev libmfxgen1 intel-opencl-icd \
#   intel-level-zero-gpu level-zero level-zero-dev initramfs-tools driverctl libva-wayland2 libva-dev libva-drm2 \
#   libva-glx2 libva-wayland2 libva-x11-2 libva2 libgl1-mesa-dev vainfo libd3dadapter9-mesa libgl1-mesa-dri libgl1-mesa-glx \
#   libglapi-mesa libgles2-mesa libosmesa6 mesa-common-dev mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers \
#   libwayland-egl1-mesa libosmesa6-dev libglx-mesa0 libgles2-mesa-dev libd3dadapter9-mesa-dev libegl-mesa0 libegl1-mesa \
#   libegl1-mesa-dev libgbm-dev libgbm1 grub-efi-amd64-signed shim-signed openssh-server docker.io linux-image-*  \
#   intel-gsc libmetee libmetee-dev  intel-igc-cm

colored_output "Kernel update completed successfully" green
colored_output "Pleaes Reboot the system..." blue
#reboot -h now
