#!/bin/bash

set -ex
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"

USERNAME="devcloud"
INSTALL_DOCKER=true

for arg in "$@"
do
    case $arg in
        --no-docker)
        INSTALL_DOCKER=false
        ;;
    esac
done

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
# add user to render group
sudo usermod -aG render ${USERNAME}

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
[ -n "$OMMIT_SERVICE_START" ] && sudo systemctl start set-cpufreq-governor.service

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
    clinfo \
    autoconf \
    automake \
    libcurl4-openssl-dev

# install and setup Docker
if $INSTALL_DOCKER; then
    # install and setup Docker
    colored_output "Adding Docker repository and installing Docker..." blue
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor | sudo sh -c "cat > /usr/share/keyrings/docker-archive-keyring.gpg"
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # add devcloud user to docker group
    colored_output "Adding ${USERNAME} to docker group..." blue
    sudo usermod -aG docker ${USERNAME}
fi

# install xpu-smi
# https://dgpu-docs.intel.com/driver/installation.html#ubuntu-server
sudo apt-get install -y xpu-smi

# ulimit tweaks
colored_output "Setting ulimit values..." blue
echo "ulimit -n 65535" | sudo tee -a /etc/security/limits.conf
echo "ulimit -u 65535" | sudo tee -a /etc/security/limits.conf


# inform user
colored_output "Cleanup..." blue
sudo apt -y autoremove

if [ -z "$OMMIT_REBOOT" ]
then
    colored_output "Setup completed. Rebooting in 10 seconds..." blue
    sleep 10
    sudo reboot
fi