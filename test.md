| File Name                  | Description                                      |
|---------------------------|--------------------------------------------------|
├── LICENSE
├── Readme.md
├── base
│   ├── [01_init_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/basinit_setup.sh)           | Initialize the server     |
│   ├── [02_kernel_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/2_kernel_setup.sh)         | Install and setup the required kernel version    |
│   ├── [03_gpu_drivers_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/3_gpu_drivers_setup.sh)    | Install  the Intel GPU drivers, runtimes      |
│   ├── [04_hold-packages.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/4_hold-packages.sh)        | Prevent package updates from breaking compatibility |
│   ├── [05_env_dev_utils_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/5_env_dev_utils_setup.sh)  | Install and setup the required tools and setup env|
│   ├── [06_conda_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/6_conda_setup.sh)          | Install and configure the Conda package manager  |
│   ├── [07_basekit_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/7_basekit_setup.sh)        | Install the required development toolkits        |
│   ├── [08_motd_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/8_motd_setup.sh)           | Customize the server login message               |
│   ├── [09_cleanup.sh](https://github.com/rahulunair/xpu_setup/blob/main/base/9_cleanup.sh)              | Clean up any unnecessary packages and files      |
│   └── Readme.md
├── hpc
│   ├── [01_hpckit_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/hpc/01_hpckit_setup.sh)        | Install hpckit in addition to base development toolkit        |
│   └── [02_motd_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/hpc/8_motd_setup.sh)           | Customize the server login message               |
├── renderkit
│   ├── [01_renderkit_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/renderkit/01_renderkit_setup.sh)        | Install hpckit in addition to base development toolkit        |
│   └── [02_motd_setup.sh](https://github.com/rahulunair/xpu_setup/blob/main/renderkit/8_motd_setup.sh)           | Customize the server login message               |
├── test.md
└── utils
    └── update_kernel.py
