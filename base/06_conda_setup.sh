#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
source /opt/intel/oneapi/setvars.sh --force
export LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/latest/lib:$LD_LIBRARY_PATH

alias sudo="sudo -E"
alias sudo=" "
AI_PKGS=false
DEFAULT=false

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


if [ $# -eq 0 ]; then
    colored_output "No flags provided. Available flags are --ai-pkgs and --default." yellow
    exit 1
fi

for arg in "$@"; do
    if [ "$arg" = "--ai-pkgs" ]; then
        AI_PKGS=true
    elif [ "$arg" = "--default" ]; then
        DEFAULT=true
    fi
done

install_miniconda() {
    colored_output "conda not found. Downloading and installing Miniconda..." blue
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

get_conda_path() {
    if command -v conda &> /dev/null; then
        CONDA_PATH=$(dirname $(which conda))
        echo "$CONDA_PATH/conda"
    else
        echo "/opt/miniconda/bin/conda"
    fi
}

install_packages() {
    local CONDA_PATH=$(get_conda_path)
    colored_output "Installing JupyterLab, ipywidgets, and IPython..." blue
    sudo $CONDA_PATH install -c conda-forge jupyterlab -y
    sudo $CONDA_PATH run pip install ipywidgets ipython
}

get_default_python_version() {
    if command -v conda &> /dev/null; then
        local full_version=$(conda run python --version | cut -d ' ' -f 2)
        echo "${full_version%.*}"
    else
        echo "3.9"
    fi
}



install_ai_packages() {
    local CONDA_PATH=$(get_conda_path)
    local DEFAULT_PYTHON_VERSION=$(get_default_python_version)
    local envs=("pytorch_xpu") #("pytorch_cpu" "tensorflow_cpu" "openvino" "pytorch_xpu" "tensorflow_xpu")

    for env in ${envs[@]}
    do
        sudo $CONDA_PATH create -n $env python=$DEFAULT_PYTHON_VERSION -y
        sudo $CONDA_PATH run -n $env pip install ipython jupyterlab ipykernel
        if [[ "$env" == "pytorch_cpu" ]] ; then
            sudo $CONDA_PATH run -n $env pip install intel_extension_for_pytorch -f https://developer.intel.com/ipex-whl-stable-cpu
            sudo $CONDA_PATH run -n $env pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        elif [[ "$env" == "tensorflow_cpu" ]] ; then
            sudo $CONDA_PATH run -n $env pip install --upgrade intel-extension-for-tensorflow[cpu]
        elif [[ "$env" == "openvino" ]] ; then
            sudo $CONDA_PATH run -n $env pip install openvino
            sudo $CONDA_PATH run -n $env pip install openvino-dev
        elif [[ "$env" == "tensorflow_xpu" ]] ; then
            sudo $CONDA_PATH run -n $env pip install --upgrade intel-extension-for-tensorflow[gpu]
        elif [[ "$env" == "pytorch_xpu" ]] ; then
            #sudo $CONDA_PATH run -n $env pip install torch==2.1.0a0 torchvision==0.16.0a0 torchaudio==2.1.0a0 intel-extension-for-pytorch==2.1.10+xpu --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/cn/
	    #sudo $CONDA_PATH run -n $env pip install --pre --upgrade bigdl-llm[xpu_2.1] -f https://developer.intel.com/ipex-whl-stable-xpu
	    #sudo $CONDA_PATH run -n $env pip install datasets transformers==4.34.0 peft==0.5.0 accelerate==0.23.0
	    #sudo $CONDA_PATH run -n $env pip install https://intel-extension-for-pytorch.s3.amazonaws.com/ipex_stable/xpu/oneccl_bind_pt-2.1.100%2Bxpu-cp39-cp39-linux_x86_64.whl 
	    
	    # build and install deepspeed
	    local tmp_build_dir=$(mktemp -d)
            git clone https://github.com/microsoft/DeepSpeed.git "$tmp_build_dir/DeepSpeed"
            pushd "$tmp_build_dir/DeepSpeed"
            git checkout 4fc181b0
            $CONDA_PATH run -n $env python setup.py bdist_wheel
            local wheel_path=$(find . -name 'deepspeed*.whl')
            popd
            sudo $CONDA_PATH run -n $env pip install "$tmp_build_dir/DeepSpeed/$wheel_path"
            #rm -rf "$tmp_build_dir"
	    
	    # build & install intel extension for deepspeed
	    local tmp_build_dir_intel=$(mktemp -d)
	    git clone https://github.com/intel/intel-extension-for-deepspeed.git "$tmp_build_dir_intel/intel-extension-for-deepspeed"
	    pushd "$tmp_build_dir_intel/intel-extension-for-deepspeed"
	    git checkout ec33277
	    $CONDA_PATH run -n $env python setup.py bdist_wheel
	    local wheel_path_intel=$(find . -name 'intel_extension_for_deepspeed*.whl')
	    popd
	    sudo $CONDA_PATH run -n $env pip install "$tmp_build_dir_intel/intel-extension-for-deepspeed/$wheel_path_intel"
    	    
	    #rm -rf "$tmp_build_dir_intel"
	    #sudo $CONDA_PATH run -n $env pip install git+https://github.com/microsoft/DeepSpeed.git@4fc181b0
	    #sudo $CONDA_PATH run -n $env pip install git+https://github.com/intel/intel-extension-for-deepspeed.git@ec33277
	    sudo $CONDA_PATH run -n $env pip install mpi4py scipy bitsandbytes
	    sudo $CONDA_PATH run -n $env -c conda-forge -y gperftools=2.10
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if ! command -v conda &> /dev/null; then
        install_miniconda
    else
        CONDA_PATH=$(get_conda_path)
        colored_output "Conda is already installed at $CONDA_PATH" yellow
    fi
    if [ "$DEFAULT" = true ] ; then
    	install_packages
    fi
    if [ "$AI_PKGS" = true ] ; then
        install_ai_packages
    fi
    colored_output "Installation completed!" green
fi
