#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"

colored_output() {
    local message=$1
    local color=$2
    case $color in
        red)     echo "\e[31m$message\e[0m\n" ;;
        green)   echo "\e[32m$message\e[0m\n" ;;
        yellow)  echo "\e[33m$message\e[0m\n" ;;
        blue)    echo "\e[34m$message\e[0m\n" ;;
        *)       echo "$message\n" ;;
    esac
}

# Update system
colored_output "Updating system..." blue
sudo apt-get update &&\
	sudo apt-get upgrade -y

# Install the kernel and headers
KERNEL_VERSION="5.15.0-57"
colored_output "Checking if kernel ${KERNEL_VERSION}-generic is installed, set as default, and running..." blue

if dpkg -l | grep -q "linux-image-${KERNEL_VERSION}-generic"; then
    colored_output "Kernel ${KERNEL_VERSION}-generic is already installed." yellow
else
    colored_output "Installing kernel ${KERNEL_VERSION}-generic..." blue
    sudo apt-get install -y --install-suggests "linux-image-${KERNEL_VERSION}-generic"
fi

colored_output "Setting kernel ${KERNEL_VERSION}-generic as the default kernel..." blue
sudo sed -i "s/GRUB_DEFAULT=.*/GRUB_DEFAULT=\"1> $(echo $(($(awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg \
| grep -no '5.15.0-57' | sed 's/:/\n/g' | head -n 1)-2)))\"/" /etc/default/grub

sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"$(echo $(awk -F'="' '$1  == "GRUB_CMDLINE_LINUX_DEFAULT" {print $2}'  \
/etc/default/grub | tr -d '"') | sed 's/pci=realloc=off//g') pci=realloc=off\"/" /etc/default/grub

sudo  update-grub

colored_output "Rebooting in 10 seconds to apply the new kernel..." blue
sleep 10
sudo reboot
