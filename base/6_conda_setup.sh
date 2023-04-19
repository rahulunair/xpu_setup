#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"

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

install_miniconda() {
    colored_output "Miniconda not found. Downloading and installing..." blue
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    sudo -u devcloud ./Miniconda3-latest-Linux-x86_64.sh -b -p /home/devcloud/miniconda
    sudo -u devcloud /home/devcloud/miniconda/bin/conda init bash
    sudo rm -rf ./Miniconda3-latest-Linux-x86_64.sh
}

install_packages() {
    colored_output "Installing JupyterLab, ipywidgets, and IPython..." blue
    sudo -u devcloud /home/devcloud/miniconda/bin/conda install -c conda-forge jupyterlab -y
    sudo -u devcloud /home/devcloud/miniconda/bin/pip install ipywidgets ipython
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if ! command -v conda &> /dev/null; then
        install_miniconda
    else
        colored_output "Miniconda is already installed." yellow
    fi

    install_packages
    colored_output "Installation completed!" green
fi

