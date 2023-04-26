### Set Up additional Intel oneAPI Components

⚠️ **Warning**: Follow these **base install steps in order** before executing the following steps.

Installs Intel Render-Kit in addition to Intel Base-Kit from initial setup.

1.  Install Packages from Intel Basekit

```bash
sudo ./01_renderkit_setup.sh
```

Customizes MOTD to indicate Render kit has been installed in addition to Base kit.

2.  Set Up the Message of the Day

```bash
sudo ./02_motd_setup.sh
```