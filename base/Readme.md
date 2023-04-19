## setup for base images with kernel, gpu drivers, basekit and other dev tools

Set of scripts to configure an Intel GPU server

It is important to execute the scripts one by one:

conda\_setup.sh  env\_dev\_utils.sh  gpu\_drivers.sh  hold-packages.sh  init.sh  kernel\_setup.sh  Readme.md

### Prerequesites

Set up base os using Ubuntu cloud image for jammy (22.04) from: https://cloud-images.ubuntu.com/jammy/current/

After the Os has been installed please follow along to create a base configuration with all required dev tools.

1.  init environment

Update, upgrade Os and add essential tools required for further setup:

```bash
sudo ./init.sh
```

2.  kernel setup

Setup kernel based on intel [GPU docs](https://dgpu-docs.intel.com/), here we are assuming that you are setting up an Intel GPU Max series GPU

```bash
sudo ./kernel_setup.sh
```

This script will setup the recommended kernel, make it default and reboots the machine

Warning: At this stage the system will reboot to ensure that the required kernel is the one being used, if not setup will fail

3.  GPU drivers setup

Setup up kernel mod and user mod drivers from intel GPU repos

```bash
sudo ./gpu_drivers.sh
```

This will install kernel modules required for the kernel to identify the GPU, runtime and develper drivers.

4.  Envinronment setup and develper utilities

```bash
sudo ./env_dev_utils.sh
```

Create a user `devcloud`, install docker, setup CPU scaling governers to performance, add user `devcloud` to `render` and `docker` group. Install essential dev utilities.

5.  Setup miniconda and install required packages

```bash
sudo ./conda_setup.sh
```

Install miniconda to the devcloud environment, install packages like jupyterhub ipython etc to the base environment

6.  Install packages from intel basekit

```bash
sudo ./basekit_setup.sh
```

Add intel basekit repos, install core packages from intel basekit

7.  Setup message of the day

```bash
sudo ./motd_setup.sh
```

setup message of the day for devcloud user
