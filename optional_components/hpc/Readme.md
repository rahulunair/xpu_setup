### Set Up additional Intel oneAPI Components

⚠️ **Warning**: Follow the **base install steps in order** before running this additional step.

Installs Intel HPC-Kit in addition to Intel Base-Kit from initial setup.

1.  Install Packages from Intel Basekit

```bash
sudo ./01_hpckit_setup.sh
```

Customizes MOTD to indicate HPC kit has been installed in addition to Base kit.

2.  Set Up the Message of the Day

```bash
sudo ./02_motd_setup.sh
```