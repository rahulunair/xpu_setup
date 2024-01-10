#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export LD_LIBRARY_PATH=/opt/intel/oneapi/intelpython/python3.9/lib/libgomp.so:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/intel/oneapi/intelpython/python3.9/lib/python3.9/site-packages/xgboost/lib/libxgboost.so:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/opt/intel/oneapi/mkl/latest/lib:$LD_LIBRARY_PATH
export PATH=/opt/intel/oneapi/mpi/latest/bin:$PATH
export LD_LIBRARY_PATH=/opt/intel/oneapi/mpi/latest/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/opt/intel/oneapi/mpi/latest/include:$C_INCLUDE_PATH
export MPICC=/opt/intel/oneapi/mpi/latest/bin/mpicc
export PATH=/opt/intel/oneapi/ccl/latest/bin:$PATH
export LD_LIBRARY_PATH=/opt/intel/oneapi/ccl/latest/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/opt/intel/oneapi/ccl/latest/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/opt/intel/oneapi/ccl/latest/include:$CPLUS_INCLUDE_PATH


alias sudo="sudo -E"
AI_PKGS=false
DEFAULT=false

change_dir_ownership() {
    local dir_path=$1
    local action=$2

    if [ "$action" == "take" ]; then
        # Capture and return the original owner and group
        local original_owner=$(stat -c '%U:%G' $dir_path)
        sudo chown -R $(whoami) $dir_path
        echo $original_owner
    elif [ "$action" == "restore" ]; then
        # Restore to the original owner and group
        local original_owner=$3
        sudo chown -R $original_owner $dir_path
    fi
}

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

get_conda_envs_dir() {
    local conda_executable=$(get_conda_path)
    local envs_dir=$($conda_executable info --envs | grep 'base' | awk '{print $3}')
    echo $envs_dir
}

install_ai_packages() {
    local CONDA_PATH=$(get_conda_path)
    local DEFAULT_PYTHON_VERSION=$(get_default_python_version)
    local oneccl_bind_python_version=$(echo $DEFAULT_PYTHON_VERSION | tr -d '.')
    local conda_envs_dir=$(get_conda_envs_dir)
    local original_owner=$(change_dir_ownership $conda_envs_dir "take")
    local envs=("pytorch-gpu-latest") #("pytorch-cpu" "tensorflow-cpu" "openvino" "pytorch-gpu-latest" "tensorflow-gpu-latest")
    echo "Using default python version ${DEFAULT_PYTHON_VERSION}"
    for env in ${envs[@]}
    do
        $CONDA_PATH create -n $env python=$DEFAULT_PYTHON_VERSION -y
	local python_executable=$($CONDA_PATH run -n $env which python)

        $python_executable -m pip install ipython jupyterlab ipykernel
        if [[ "$env" == "pytorch_cpu" ]] ; then
            $python_executable -m pip install intel_extension_for_pytorch -f https://developer.intel.com/ipex-whl-stable-cpu
            $python_executable -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        elif [[ "$env" == "tensorflow_cpu" ]] ; then
            $python_executable -m pip install --upgrade intel-extension-for-tensorflow[cpu]
        elif [[ "$env" == "openvino" ]] ; then
            $python_exectuable -m pip install openvino
            $python_executable -m pip install openvino-dev
        elif [[ "$env" == "tensorflow-gpu-latest" ]] ; then
            $python_executable -m pip install --upgrade intel-extension-for-tensorflow[gpu]
        elif [[ "$env" == "pytorch-gpu-latest" ]] ; then
            $python_executable -m pip install torch==2.1.0a0 torchvision==0.16.0a0 torchaudio==2.1.0a0 intel-extension-for-pytorch==2.1.10+xpu --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/cn/
	     $python_executable -m pip install --pre --upgrade bigdl-llm[xpu_2.1] -f https://developer.intel.com/ipex-whl-stable-xpu
	     $python_executable -m pip install datasets transformers==4.34.0 peft==0.5.0 accelerate==0.23.0
	     $python_executable -m pip install https://intel-extension-for-pytorch.s3.amazonaws.com/ipex_stable/xpu/oneccl_bind_pt-2.1.100%2Bxpu-cp$oneccl_bind_python_version-cp$oneccl_bind_python_version-linux_x86_64.whl 
	     $python_executable -m pip install mpi4py
	     $python_executable -m pip install scipy bitsandbytes
	     $python_executable -m pip install git+https://github.com/microsoft/DeepSpeed.git@4fc181b0
	     $python_executable -m pip install git+https://github.com/intel/intel-extension-for-deepspeed.git@ec33277
	    $CONDA_PATH install -c conda-forge -y gperftools=2.10
	    change_dir_ownership $conda_envs_dir "restore" $original_owner

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
