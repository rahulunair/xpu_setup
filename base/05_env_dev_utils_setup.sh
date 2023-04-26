#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"

USERNAME="devcloud"
XPU_SMI_URL=$(curl -sL "https://github.com/intel/xpumanager/releases" | grep -oP "href=\"\K[^\"']*(xpu-smi_.*_u22\.04_amd64\.deb\")" | sed 's/"$//; s/^/https:\/\/github.com/')
XPU_DEB_NAME=$(basename "$XPU_SMI_URL")

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

# create devcloud user with sudo powers
colored_output "Creating user ${USERNAME} with sudo powers..." blue
if id -u "${USERNAME}" >/dev/null 2>&1; then
    colored_output "User ${USERNAME} already exists." yellow
else
    sudo adduser --gecos "" ${USERNAME}
    sudo usermod -aG sudo ${USERNAME}
fi

# set CPU governor to performance
colored_output "Setting CPU governor to performance..." blue

# create a systemd service file for setting CPU governor
cat << EOF | sudo tee /etc/systemd/system/set-cpufreq-governor.service
[Unit]
Description=Set CPU governor to performance

[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"

[Install]
WantedBy=multi-user.target
EOF

# enable and start the service
sudo systemctl enable set-cpufreq-governor.service
sudo systemctl start set-cpufreq-governor.service

# install required packages
colored_output "Installing required packages..." blue
sudo apt-get update
sudo apt-get install -y \
    pkg-config \
    build-essential \
    cmake \
    neovim \
    vim \
    cpufrequtils \
    hwinfo \
    vainfo \
    net-tools \
    clinfo

# install and setup Docker
colored_output "Adding Docker repository and installing Docker..." blue
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor | sudo sh -c "cat > /usr/share/keyrings/docker-archive-keyring.gpg"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# add devcloud user to docker and render groups
colored_output "Adding ${USERNAME} to docker and render groups..." blue
sudo usermod -aG docker,render ${USERNAME}

# install xpu-smi
wget "$XPU_SMI_URL"
sudo apt install -y ./"$XPU_DEB_NAME"
sudo rm -rf ./"$XPU_DEB_NAME"

# inform user
colored_output "Cleanup..." blue
sudo apt -y autoremove
colored_output "Setup completed. Rebooting in 10 seconds..." blue
sleep 10
sudo reboot
