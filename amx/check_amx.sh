#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
REQUIRED_KERNEL_VERSION="5.15"
AMX_FLAGS=("amx_bf16" "amx_tile" "amx_int8")
OUTPUT="____________________________________________"

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

CPU_NAME=$(lscpu | grep "Model name" | cut -d ':' -f 2 | xargs)
KERNEL_VERSION=$(uname -r | cut -d '-' -f 1)

OUTPUT+="\nCPU Name: ${CPU_NAME}"
OUTPUT+="\nKernel Version: ${KERNEL_VERSION}"

if [ "$(printf '%s\n' "$REQUIRED_KERNEL_VERSION" "$KERNEL_VERSION" | sort -V | head -n1)" = "$REQUIRED_KERNEL_VERSION" ]; then 
    OUTPUT+="\nKernel version is above/equal to 5.15"
else 
    OUTPUT+="\nKernel version is below 5.15. Please upgrade the kernel"
    exit 1
fi

LSCPU_FLAGS=$(lscpu | grep Flags | cut -d ':' -f 2)
for flag in ${AMX_FLAGS[@]}
do
    if [[ $LSCPU_FLAGS == *"$flag"* ]]; then
        OUTPUT+="\nFlag ${flag} is available"
    else
        OUTPUT+="\nFlag ${flag} is not available. Please check the Intel 4th Gen Xeon Scalable CPU"
        exit 1
    fi
done

colored_output "Installing PyTorch..." blue
# Install Numpy, Pytorch and torchvision
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cpu
pip3 install numpy

colored_output "Running a PyTorch resnet18 training loop to check if bf16 and AMX kernels are being used... ( ~ 30 seconds)" blue
cat <<EOF > resnet18_test.py
import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms
from torchvision.models import resnet18, ResNet18_Weights
import os
from torch.utils.data import DataLoader, TensorDataset

resnet18 = resnet18(weights=ResNet18_Weights.IMAGENET1K_V1)
num_ftrs = resnet18.fc.in_features
resnet18.fc = nn.Linear(num_ftrs, 10)  # assuming we have 10 classes
resnet18 = resnet18.to(torch.bfloat16)

inputs = torch.randn(100, 3, 224, 224).to(torch.bfloat16)
targets = torch.randint(0, 10, (100,)).to(torch.bfloat16)
dataset = TensorDataset(inputs, targets)
dataloader = DataLoader(dataset, batch_size=4, shuffle=True, num_workers=2)

criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.SGD(resnet18.parameters(), lr=0.001, momentum=0.9)

for epoch in range(1):
    for i, data in enumerate(dataloader, 0):
        inputs, labels = data
        optimizer.zero_grad()
        outputs = resnet18(inputs)
        loss = criterion(outputs, labels.long())
        loss.backward()
        optimizer.step()
EOF

ONEDNN_VERBOSE=1 python3 resnet18_test.py > onednn_verbose.log

if grep -q "amx_bf16" onednn_verbose.log; then
    OUTPUT+="\nAMX BF16 is available and can be used by PyTorch"
else
    OUTPUT+="\nAMX BF16 is available but cannot be used in PyTorch"
fi

OUTPUT+="\n____________________________________________\n"
rm resnet18_test.py
rm onednn_verbose.log
echo -e $OUTPUT
