import os
import re
import requests
from bs4 import BeautifulSoup

KERNEL_URL = "https://dgpu-docs.intel.com/_sources/installation-guides/ubuntu/ubuntu-jammy-max.md.txt"
DEFAULT_KERNEL_NAME = "linux-image-5.15.0-57-generic"

response = requests.get(KERNEL_URL)
soup = BeautifulSoup(response.text, 'html.parser')
kernel_name = re.search(r"install-suggests linux-image-.*-generic", str(soup))
kernel_name = kernel_name.group(0).split()[1] if kernel_name else DEFAULT_KERNEL_NAME
kernel_version = '-'.join(kernel_name.split('-')[2:4])

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

