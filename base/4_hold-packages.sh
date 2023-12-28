#!/bin/bash

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


MIN_KERNEL_VERSION="5.15.0"

# Check kernel version
colored_output "Checking kernel version..." blue
KERNEL_VERSION=$(uname -r | cut -d'-' -f1)
if [[ "$(printf '%s\n' "$MIN_KERNEL_VERSION" "$CURRENT_KERNEL_VERSION" | sort -V | head -n1)" != "$MIN_KERNEL_VERSION" ]]; then
    colored_output "Error: Kernel version must be $MIN_KERNEL_VERSION or higher." red
    exit 1
fi

KERNEL_PACKAGE="linux-image-${KERNEL_VERSION}-generic"
KERNEL_HEADER_PACKAGE="linux-headers-${KERNEL_VERSION}-generic"
INTEL_PACKAGES=("intel-i915-dkms" "intel-fw-gpu")

colored_output "Holding kernel, kernel headers, and Intel packages..." blue
sudo apt-mark hold ${KERNEL_PACKAGE} ${KERNEL_HEADER_PACKAGE} ${INTEL_PACKAGES[@]}
colored_output "The following packages have been held:" yellow
echo ${KERNEL_PACKAGE} ${KERNEL_HEADER_PACKAGE} ${INTEL_PACKAGES[@]}
