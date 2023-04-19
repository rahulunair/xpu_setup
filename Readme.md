## Intel GPU Max dGPU Server Setup Guide

This guide provides step-by-step instructions for setting up an Intel GPU Max dGPU server . This repository contains a series of scripts that automate the configuration process, making it easier and more efficient.

### Prerequisites

Before you begin, ensure that you have set up the base operating system using the Ubuntu cloud image for Jammy (22.04) from the following link: https://cloud-images.ubuntu.com/jammy/current/

### xpu\_setup Repository Structure

The **'xpu\_setup'** repository has the following structure:

```bash
xpu_setup/
├── base
│   ├── basekit_setup.sh
│   ├── conda_setup.sh
│   ├── env_dev_utils.sh
│   ├── gpu_drivers.sh
│   ├── hold-packages.sh
│   ├── init.sh
│   ├── kernel_setup.sh
│   ├── motd_setup.sh
│   └── Readme.md
└── Readme.md
```

### How to setup and configure?

To follow along and setup a server with intel descrete GPUs and base configuration:

Clone the repository:

```bash
git clone https://github/unrahul/xpu_setup
```

Change directory to base inside xpu\_setup and follow the Readme.md inside 'base':

```bash
cd xpu_verify/base
```
