import os
import re
import requests
import sys
from bs4 import BeautifulSoup
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--arc", action="store_true", help="Use the Intel ARC GPU URL.")
args = parser.parse_args()

if args.arc:
    KERNEL_URL = "https://dgpu-docs.intel.com/_sources/installation-guides/ubuntu/ubuntu-jammy-arc.md.txt"
    DEFAULT_KERNEL_NAME = "linux-image-5.17.0-35-generic"
else:
    KERNEL_URL = "https://dgpu-docs.intel.com/_sources/installation-guides/ubuntu/ubuntu-jammy-max.md.txt"
    DEFAULT_KERNEL_NAME = "linux-image-5.15.0-73-generic"

def update_kernel_version(KERNEL_URL, DEFAULT_KERNEL_NAME):
    try:
        response = requests.get(KERNEL_URL)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        kernel_name = re.search(r"install-suggests linux-image-.*-generic", str(soup))
        kernel_name = kernel_name.group(0).split()[1] if kernel_name else DEFAULT_KERNEL_NAME
        kernel_version = '-'.join(kernel_name.split('-')[2:4])
        print("updating kernel")
        script_path = os.path.join('base', '2_kernel_setup.sh')
        with open(script_path, 'r') as file:
            script_content = file.read()

        updated_script_content = re.sub(
            r'(KERNEL_NAME=).*',
            f"\\1\"{kernel_name}\"",
            script_content
        )
        updated_script_content = re.sub(
            r'(KERNEL_VERSION=).*',
            f"\\1\"{kernel_version}\"",
            updated_script_content
        )
        if script_content != updated_script_content:
            with open(script_path, 'w') as file:
                file.write(updated_script_content)
    except Exception as e:
        print(f"Couldn't fetch kernel info from the docs, please check the docs and update the script: {e}")

update_kernel_version(KERNEL_URL, DEFAULT_KERNEL_NAME)

