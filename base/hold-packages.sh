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

KERNEL_VERSION="5.15.0-57"
KERNEL_PACKAGE="linux-image-${KERNEL_VERSION}-generic"
KERNEL_HEADER_PACKAGE="linux-headers-${KERNEL_VERSION}-generic"
INTEL_PACKAGES=("intel-i915-dkms" "intel-fw-gpu" "intel-platform-vsec-dkms" "intel-platform-cse-dkms")

colored_output "Holding kernel, kernel headers, and Intel packages..." blue
sudo apt-mark hold ${KERNEL_PACKAGE} ${KERNEL_HEADER_PACKAGE} ${INTEL_PACKAGES[@]}
colored_output "The following packages have been held:" yellow
echo ${KERNEL_PACKAGE} ${KERNEL_HEADER_PACKAGE} ${INTEL_PACKAGES[@]}
