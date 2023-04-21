#!/bin/bash

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

# Update system
colored_output "Updating system..." blue
sudo apt-get update &&\
    sudo apt-get upgrade -y

# Install the kernel and headers, try to get the latest from the docs, if not use default
KERNEL_URL="https://dgpu-docs.intel.com/_sources/installation-guides/ubuntu/ubuntu-jammy-max.md.txt"
KERNEL_NAME=$(curl -s "${KERNEL_URL}" | grep -o "install-suggests linux-image-.*-generic" | awk -F' ' '{print $2}') || KERNEL_NAME="linux-image-5.15.0-57-generic"
KERNEL_VERSION=$(echo $KERNEL_NAME | awk -F'-' '{print $3"-"$4}') || KERNEL_VERSION="5.15.0-57"

colored_output "Checking if kernel ${KERNEL_NAME} is installed..." blue

if dpkg -l | grep -q "${KERNEL_NAME}"; then
    colored_output "Kernel ${KERNEL_NAME} is already installed." yellow
else
    colored_output "Installing kernel ${KERNEL_VERSION}-generic..." blue
    sudo apt-get install -y --install-suggests "${KERNEL_NAME}"
fi

colored_output "Setting kernel ${KERNEL_VERSION}-generic as the default kernel..." blue
sudo sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=\"1> $(echo $(($(awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg \
| grep -no '${KERNEL_VERSION}' | sed 's/:/\n/g' | head -n 1)-2)))\"/" /etc/default/grub
sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$(echo $(awk -F'="' '$1  == "GRUB_CMDLINE_LINUX_DEFAULT" {print $2}'  \
/etc/default/grub | tr -d '"') | sed 's/pci=realloc=off//g') pci=realloc=off\"/" /etc/default/grub

sudo  update-grub

# Check if the correct kernel is set as default
if grep -q "${KERNEL_VERSION}-generic" /boot/grub/grub.cfg; then
    colored_output "Kernel ${KERNEL_VERSION}-generic is set as the default kernel." green
else
    colored_output "ERROR: Failed to set kernel ${KERNEL_VERSION}-generic as the default kernel." red
    exit 1
fi

colored_output "Rebooting in 10 seconds to apply the new kernel..." blue
sleep 10
sudo reboot
