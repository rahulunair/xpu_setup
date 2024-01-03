#!/bin/bash

# Function to display colored output
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

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    colored_output "This script must be run as root" red
    exit 1
fi

# Install driverctl
colored_output "Installing driverctl..." blue
apt-get update
apt-get install -y driverctl

# Check device linked to intel-pmt
colored_output "Checking for device linked to intel-pmt..." blue
DEVICE=$(driverctl list-devices | grep -iE "pmt" | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    colored_output "No device found for intel-pmt" red
    exit 1
fi
colored_output "Device found: $DEVICE" green

# Set override to intel_vsec
colored_output "Setting override to intel_vsec for device $DEVICE..." blue
driverctl set-override "$DEVICE" "intel_vsec"

# Verification
colored_output "Verifying VSEC usage for Intel Data Center GPU Max Series..." blue
for d in 8086:09A7 8086:4F93 8086:4F95; do
    lspci -k -d "$d"
done

colored_output "Script completed. Please review the output above for verification." green
