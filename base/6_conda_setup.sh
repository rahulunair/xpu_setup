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
    sudo ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda
    sudo rm -rf ./Miniconda3-latest-Linux-x86_64.sh
    
    # Set proper permissions for /opt/miniconda
    sudo chown -R root:users /opt/miniconda
    sudo chmod -R 775 /opt/miniconda
    
    # Add Conda environment variables for all users
    echo 'export PATH="/opt/miniconda/bin:$PATH"' | sudo tee /etc/profile.d/conda.sh
    echo '. /opt/miniconda/etc/profile.d/conda.sh' | sudo tee -a /etc/profile.d/conda.sh
    echo 'conda activate base' | sudo tee -a /etc/profile.d/conda.sh
    # Set correct permissions for /etc/profile.d/conda.sh
    sudo chmod 644 /etc/profile.d/conda.sh
}

install_packages() {
    colored_output "Installing JupyterLab, ipywidgets, and IPython..." blue
    sudo /opt/miniconda/bin/conda install -c conda-forge jupyterlab -y
    sudo /opt/miniconda/bin/pip install ipywidgets ipython
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
