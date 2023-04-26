#!/bin/bash

cat >custom_motd.sh <<'EOF'
#!/bin/bash
echo 
echo -e "---------------------------------------------------------------------"
echo ""
echo -e "\033[1;33mWARNING:\033[0m Kernel and GPU drivers have been intentionally held back."
echo -e "Feel free to update the system, but please \033[1;31mrefrain from changing\033[0m the kernel and GPU"
echo -e "drivers to maintain a stable and supported environment."
echo ""
echo -e "\033[1;34mThis system has the Intel Base-kit installed. To activate it, enter:\033[0m"
echo -e "source /opt/intel/oneapi/setvars.sh"
echo -e "Additional oneAPI components can be installed using apt install <package-name>," 
echo -e "For e.g: sudo apt install intel-hpckit, for more info, visit:"
echo -e "<https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-linux/2023-0/apt.html>"
echo ""
echo -e "\033[1;34mTo run AI workloads using Docker and Intel GPU extensions, follow these steps:\033[0m"
echo ""
echo -e "1. Pull the PyTorch Docker image with Intel extensions:"
echo -e '   IMAGE_NAME="intel/intel-extension-for-pytorch"'
echo -e '   IMAGE_TAG="xpu-max"'
echo -e '   docker pull "$IMAGE_NAME:$IMAGE_TAG"'
echo ""
echo -e "2. Run the PyTorch Docker image:"
echo -e '   CURRENT_DIR="$(pwd)"'
echo -e '   docker run -it --rm \'
echo -e '       -v "$CURRENT_DIR":/workspace \'
echo -e '       -v /dev/dri/by-path:/dev/dri/by-path \'
echo -e '       --device /dev/dri \'
echo -e '       --privileged \'
echo -e '       "$IMAGE_NAME:$IMAGE_TAG"'
echo ""
echo -e "3. For TensorFlow, pull the Docker image:"
echo -e '   IMAGE_NAME="intel/intel-extension-for-tensorflow"'
echo -e '   IMAGE_TAG="gpu"'
echo -e '   docker pull "$IMAGE_NAME:$IMAGE_TAG"'
echo ""
echo -e "4. Run the TensorFlow Docker image:"
echo -e '   docker run -it --rm \'
echo -e '       -v "$CURRENT_DIR":/workspace \'
echo -e '       -v /dev/dri/by-path:/dev/dri/by-path \'
echo -e '       --device /dev/dri \'
echo -e '       --privileged \'
echo -e '       "$IMAGE_NAME:$IMAGE_TAG"'
echo ""
echo -e "Once inside the Docker container, you can run your desired AI workloads."
echo ""
echo -e "\033[1;34mSystem Information:\033[0m"
echo -e "Hostname: $(hostname)"
echo -e "CPU: $(lscpu | awk '/Model name/ { $1=""; sub(/^ +/, ""); print }' | sed 's/^[[:space:]]*//')" | sed 's/name://g'                                                     
echo -e "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo -e "Disk Space: $(df -h --output=source,size,pcent / | tail -n 1)"
gpu_info=$(lspci | grep -i display | grep -i intel)
if [ -n "$gpu_info" ]; then
  gpu_name=$(echo $gpu_info | awk -F': ' '{print $2}')
  echo -e "\033[1;34mAvailable GPU:\033[0m $gpu_name"
fi
echo ""
echo -e "---------------------------------------------------------------------"
EOF

sudo apt install -y update-motd
sudo find /etc/update-motd.d/ -type f ! -name '00-custom' -exec rm {} +
sudo mv custom_motd.sh /etc/update-motd.d/99-custom
sudo chmod 755 /etc/update-motd.d/99-custom
sudo /usr/sbin/update-motd


