### Set Up Intel dGPUs with Intel oneAPI Components

⚠️ **Warning**: Follow these steps **in order** to set up your Intel GPU dGPU server.

**Update**: Added some upgrade scripts as well (10 to 12 steps), please run those after the setup as given in the readme

<p align="center">
  <img src="https://user-images.githubusercontent.com/786476/234943097-683fd36e-e032-40e2-b3f6-0ec2933722b8.png" width="500" alt="Branches Screenshot">
</p>


1. 🌍 Initialize the Environment

```bash
sudo ./1_init_setup.sh
```

Updates and upgrades the operating system, and installs essential tools required for further setup.

2. 🌽 Set Up the Kernel

```bash
sudo ./2_kernel_setup.sh
```
🍿 Sets up the recommended kernel, makes it the default, and **Reboots** the machine.

3.  🎮 Set Up GPU Drivers

```bash
sudo ./3_gpu_drivers_setup.sh
```
🚀 Installs required kernel modules, runtime, and developer drivers. **Reboots** after this stage.

4.  🔒 Hold Kernel and Kernel Modules


```bash
sudo ./4_hold-packages.sh
```
🔏 Limits updates to the kernel and kernel modules.


5. 🛠️ Set Up the Environment and Developer Utilities

```bash
sudo ./5_env_dev_utils_setup.sh
```

👤 Creates 'devcloud' user, installs Docker, sets up CPU scaling governors, and adds 'devcloud' to 'render' and 'docker' groups. Installs essential developer utilities.

6. 🐍 Set Up Miniconda and Install Required Packages

```bash
sudo ./6_conda_setup.sh
```

📦 Installs Miniconda to the 'devcloud' environment and packages like JupyterHub and IPython.

7.  📚 Install Packages from Intel Basekit, Hpckit and Renderkit

```bash
sudo ./7_basekit_setup.sh
```

🔬 Adds Intel Basekit repositories and installs core packages.

8. 📅 Set Up the Message of the Day

```bash
sudo ./8_motd_setup.sh
```

📜 Sets up a message of the day for the devcloud user, displaying available GPU and CPU, oneAPI usage instructions, and how to get other oneAPI packages.

9. 🧹 Cleanup

```bash
sudo ./9_cleanup.sh
```
🗑️ Finally, updates and removes any packages that can be autoremoved.

10. 🆙 Upgrade Kernel

```bash
sudo ./10_os_kernel_upgrade.sh
```
🔝 Upgrade OS kernel to latest 5.15 LTS.

11. 🔨 Upgrade Usermod Drivers

```bash
sudo ./11_gpu_kernel_drivers_upgrade.sh	
```

🎬 Upgrade kernel drivers to latest available version from Intel GPU repos.

12. 🛠️ Upgrade Usermod Drivers

```bash
sudo ./12_usermod_driver_upgrade.sh
```
🛠️  Add and upgrade any missing usermod drivers for GPU.

"🎉 Congratulations! 🎉 Your system is now fully equipped with the latest supported kernel and drivers. Time to dive in and start creating. Happy Hacking! 💻🚀"
