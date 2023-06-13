#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
alias sudo="sudo -E"
AI_PKGS=false

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

# check if --ai-pkgs flag is set, if set install pytorch, tensorflow and openvino xpu and cpu pkgs to environments
for arg in "$@"; do
    if [ "$arg" = "--ai-pkgs" ]; then
        AI_PKGS=true
    fi
done

install_miniconda() {
    colored_output "Miniconda not found. Downloading and installing..." blue
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    sudo ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda
    sudo rm -rf ./Miniconda3-latest-Linux-x86_64.sh
    sudo chown -R root:users /opt/miniconda
    sudo chmod -R 775 /opt/miniconda
    echo 'export PATH="/opt/miniconda/bin:$PATH"' | sudo tee /etc/profile.d/conda.sh
    echo '. /opt/miniconda/etc/profile.d/conda.sh' | sudo tee -a /etc/profile.d/conda.sh
    sudo chmod 644 /etc/profile.d/conda.sh
}

install_packages() {
    colored_output "Installing JupyterLab, ipywidgets, and IPython..." blue
    sudo /opt/miniconda/bin/conda install -c conda-forge jupyterlab -y
    sudo /opt/miniconda/bin/pip install ipywidgets ipython
}

install_ai_packages() {
    CONDA_PATH="/opt/miniconda/bin/conda"
    envs=("pytorch_cpu" "tensorflow_cpu" "openvino" "pytorch_xpu" "tensorflow_xpu")
    sudo $CONDA_PATH install -c conda-forge gperftools -y
    sudo $CONDA_PATH install -c anaconda intel-openmp -y
    for env in ${envs[@]}
    do
        sudo $CONDA_PATH create -n $env python=3.10 -y
        sudo $CONDA_PATH run -n $env python -m pip install ipython jupyterlab ipykernel
        if [[ "$env" == "pytorch_cpu" ]] ; then
            sudo $CONDA_PATH run -n $env python -m pip install intel_extension_for_pytorch -f https://developer.intel.com/ipex-whl-stable-cpu
            sudo $CONDA_PATH run -n $env python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        elif [[ "$env" == "tensorflow_cpu" ]] ; then
            sudo $CONDA_PATH run -n $env python -m pip install --upgrade intel-extension-for-tensorflow[cpu]
        elif [[ "$env" == "openvino" ]] ; then
            sudo $CONDA_PATH run -n $env python -m pip install openvino
            sudo $CONDA_PATH run -n $env python -m pip install openvino-dev
        elif [[ "$env" == "tensorflow_xpu" ]] ; then
            sudo $CONDA_PATH run -n $env python -m pip install --upgrade intel-extension-for-tensorflow[gpu]
        elif [[ "$env" == "pytorch_xpu" ]] ; then
            sudo $CONDA_PATH run -n $env python -m pip install torch==1.13.0a0+git6c9b55e intel_extension_for_pytorch==1.13.120+xpu -f https://developer.intel.com/ipex-whl-stable-xpu
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if ! command -v conda &> /dev/null; then
        install_miniconda
    else
        colored_output "Miniconda is already installed." yellow
    fi
    install_packages
    if [ "$AI_PKGS" = true ] ; then
        install_ai_packages
    fi
    colored_output "Installation completed!" green
fi
