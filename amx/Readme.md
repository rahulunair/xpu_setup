## Advanced Matrix Extensions (AMX) Setup Guide

This guide helps to set up and verify the Advanced Matrix Extensions (AMX) on an Ubuntu 22.04 server. AMX provides a significant performance boost for Artificial Intelligence (AI) workloads, especially those involving matrix operations.

The procedure comprises two parts:

1. **Kernel Update:** For the successful Virtual Machine (VM) passthrough for AMX, the system requires a kernel version equal to or greater than 5.19. We provide a script named `setup_kernel.sh` that installs this required kernel version on Ubuntu 22.04 operating systems.

2. **AMX Capabilities Verification:** Also included is a `check_amx.sh` shell script to confirm the correct setup and utilization of AMX extensions. This script installs PyTorch, executes a test program, and validates whether the system correctly identifies and uses the AMX extension. It also checks if AMX's bf16 kernels are properly employed by PyTorch.

These scripts are available in the `amx` subfolder inside the `xpu_setup` directory.

Follow the instructions below to successfully set up AMX:

0. Clone the [xpu_setup](https://github.com/rahulunair/xpu_setup.git) repo.
1. Navigate to the `amx` subfolder inside `xpu_setup`.
2. Run `setup_kernel.sh` to install the necessary kernel version. Ensure the system is Ubuntu 22.04 or compatible for successful execution.
3. Run `check_amx.sh` to install PyTorch, execute the test code, and verify AMX's presence and utilization on the system.

This setup ensures we're taking full advantage of the powerful AMX features, thereby significantly improving the performance of AI workloads.
