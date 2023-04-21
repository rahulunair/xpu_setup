## Intel GPU Max dGPU Server Setup Guide

This guide provides step-by-step instructions for setting up an Intel discrete GPUs on Ubuntu 22.04. This repository contains a series of scripts that automate the configuration process, making it easier and more efficient. Depending on your specific dGPU, you can use one of the following branches:

    - For Intel Data Center GPU Max Series (PVC) setup, use the main branch.
    - For Intel Arc (Alchemist) GPUs setup, use the arc branch.
    - For Intel Data Center GPU Flex Series (ATS) setup, use the flex branch.

### Prerequisites

Make sure to setup the base operating system on your machine using a variant of Ubuntu 22.04 (Jammy). For servers, download the [Ubuntu cloud image](https://cloud-images.ubuntu.com/jammy/current/) for Jammy (22.04). Additionally, ensure that your machine is connected to the internet before proceeding.

### xpu\_setup Repository Structure

The essential components for setting up a GPU device in the repo has the following structure:

```bash
xpu_setup/
├── base
│   ├── 1_init_setup.sh
│   ├── 2_kernel_setup.sh
│   ├── 3_gpu_drivers_setup.sh
│   ├── 4_hold-packages.sh
│   ├── 5_env_dev_utils_setup.sh
│   ├── 6_conda_setup.sh
│   ├── 7_basekit_setup.sh
│   ├── 8_motd_setup.sh
│   ├── 9_cleanup.sh
│   └── Readme.md
```

### How to setup and configure?

To follow along and setup a server with intel descrete GPUs and base configuration:

Clone the repository:

```bash
git clone https://github/unrahul/xpu_setup
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
