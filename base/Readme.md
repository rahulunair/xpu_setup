### Setup Intel dGPUs with Intel oneAPI components

⚠️ **Warning**: Follow these steps **in the order** presented to set up your Intel GPU Max dGPU server.

1.  Initialize the Environment

Update and upgrade the operating system, and install essential tools required for further setup.
```bash
sudo ./1_init_setup.sh
```
2.  Set Up the Kernel

Set up the kernel based on the Intel GPU documentation. This guide assumes you are setting up an Intel GPU Max series GPU.

**Warning:** The system will reboot after this stage to ensure that the required kernel is setup.
```bash
sudo ./2_kernel_setup.sh
```

This script will set up the recommended kernel, make it the default kernel, and reboot the machine.

3.  Set Up GPU Drivers

**Warning:** The system will reboot after this stage to ensure that the gpu drivers is setup correctly.
Set up kernel mode and user mode drivers from Intel GPU repositories:

```bash
sudo ./3_gpu_drivers_setup.sh
```

This script will install the required kernel modules for the kernel to recognize the GPU, as well as runtime and developer drivers.

4.  Hold kernel and kernel modules

Let's mark and hold the kernel and kernel modules, so that these packages are not updates without the user directly choosing to do so.

```bash
sudo ./4_hold-packages.sh
```

5.  Set Up the Environment and Developer Utilities

```bash
sudo ./5_env_dev_utils_setup.sh
```

This script will create a user named **'devcloud'**, install Docker, set up CPU scaling governors for performance, and add the **'devcloud'** user to the **'render'** and **'docker'** groups. It will also install essential developer utilities.

6.  Set Up Miniconda and Install Required Packages

```bash
sudo ./6_conda_setup.sh
```

This script will install Miniconda to the **'devcloud'** environment and install packages like JupyterHub and IPython to the base environment.

7.  Install Packages from Intel Basekit

```bash
sudo ./7_basekit_setup.sh
```

This script will add Intel Basekit repositories and install core packages from the Intel Basekit.

8.  Set Up the Message of the Day

```bash
sudo ./8_motd_setup.sh
```

This script will set up a message of the day for the devcloud user, displaying the available GPU and CPU, along with instructions on using oneAPI and how to get other oneAPI packages.

9.  Cleanup

Finally, lets update and remove any packages that can be autoremoved

```bash
sudo ./9_cleanup.sh
```
