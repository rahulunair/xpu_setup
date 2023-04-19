### Step-by-Step Setup Instructions

#### Setup process

Follow these steps in the order presented to set up your Intel GPU Max dGPU server:

1.  Initialize the Environment

Update and upgrade the operating system, and install essential tools required for further setup:

```bash
sudo ./init.sh
```

2.  Set Up the Kernel

**Warning:** The system will reboot at this stage to ensure that the required kernel is in use. If not, the setup will fail.

Set up the kernel based on the Intel GPU documentation. This guide assumes you are setting up an Intel GPU Max series GPU.

```bash
sudo ./kernel_setup.sh
```

This script will set up the recommended kernel, make it the default kernel, and reboot the machine.

3.  Set Up GPU Drivers

Set up kernel mode and user mode drivers from Intel GPU repositories:

```bash
sudo ./gpu_drivers.sh
```

This script will install the required kernel modules for the kernel to recognize the GPU, as well as runtime and developer drivers.

4.  Set Up the Environment and Developer Utilities

```bash
sudo ./env_dev_utils.sh
```

This script will create a user named **'devcloud'**, install Docker, set up CPU scaling governors for performance, and add the **'devcloud'** user to the **'render'** and **'docker'** groups. It will also install essential developer utilities.

5.  Set Up Miniconda and Install Required Packages

```bash
sudo ./conda_setup.sh
```

This script will install Miniconda to the **'devcloud'** environment and install packages like JupyterHub and IPython to the base environment.

6.  Install Packages from Intel Basekit

```bash
sudo ./basekit_setup.sh
```

This script will add Intel Basekit repositories and install core packages from the Intel Basekit.

7.  Set Up the Message of the Day

```bash
sudo ./motd_setup.sh
```

This script will set up a message of the day for the devcloud user, displaying the available GPU and CPU, along with instructions on using oneAPI and how to get other oneAPI packages.

### Conculsion

The provided documentation covers each step in detail, ensuring a smooth setup process. If you encounter any issues during the setup or have any questions, please do not hesitate to raise an issue on the GitHub repository. This will help us improve the documentation and address any potential problems promptly.
