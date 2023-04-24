## Unofficial Setup Guide for Intel discrete GPU on Linux*

This guide provides step-by-step instructions for setting up an Intel discrete GPUs on Ubuntu 22.04. This repository contains a series of scripts that automate the configuration process, making it easier and more efficient. Depending on your specific dGPU, you can use one of the following branches:

    - For Intel Data Center GPU Max Series (PVC) setup, use the main branch (default).
    - For Intel Arc (Alchemist) GPUs setup, use the arc branch.
    - For Intel Data Center GPU Flex Series (ATS) setup, use the flex branch.

### Prerequisites

Make sure to setup the base operating system on your machine using a variant of Ubuntu 22.04 (Jammy). For servers, download the [Ubuntu 22.04 cloud image](https://cloud-images.ubuntu.com/jammy/current/) (jammy). Additionally, ensure that your machine is connected to the internet before proceeding.

### xpu\_setup Repository Structure

The essential components for setting up a GPU device in the repo has the following structure:

| File Name                  | Description                                      |
|---------------------------|--------------------------------------------------|
| [1_init_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/1_init_setup.sh)           | Initialize the server     |
| [2_kernel_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/2_kernel_setup.sh)         | Install and setup the required kernel version    |
| [3_gpu_drivers_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/3_gpu_drivers_setup.sh)    | Install  the Intel GPU drivers, runtimes      |
| [4_hold-packages.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/4_hold-packages.sh)        | Prevent package updates from breaking compatibility |
| [5_env_dev_utils_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/5_env_dev_utils_setup.sh)  | Install and setup the required tools and setup env|
| [6_conda_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/6_conda_setup.sh)          | Install and configure the Conda package manager  |
| [7_basekit_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/7_basekit_setup.sh)        | Install the required development toolkits        |
| [8_motd_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/8_motd_setup.sh)           | Customize the server login message               |
| [9_cleanup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/9_cleanup.sh)              | Clean up any unnecessary packages and files      |


### How to setup and configure?

To follow along and setup a server with intel descrete GPUs and base configuration:

Clone the repository:

```bash
git clone https://github/rahulunair/xpu_setup
```
Optional step:

Switch branch to 'arc' or 'flex' if you are setting up either Intel Arc GPUs or Intel Data Center GPU Flex Series.

```bash
git checkout arc # for Intel Arc GPUs
```
Change directory to base inside xpu\_setup and follow the Readme.md inside 'base':

```bash
cd xpu_verify/base
```

After the setup is complete, you can verify if the GPU is setup correctly using the tool [xpu\_verify](https://github.com/rahulunair/xpu_verify).Additionally, you can use clinfo and hwinfo to confirm that the GPU can be successfully enumerated.

#### Conculsion

The provided documentation covers each step in detail, ensuring a smooth setup process. If you encounter any issues during the setup or have any questions, please do not hesitate to raise an issue on the GitHub repository. This will help us improve the documentation and address any potential problems promptly.

\* I have tried to be as faithful as I can to the [official guide](https://dgpu-docs.intel.com/installation-guides/index.html), but added some additional bits to make life easier.
