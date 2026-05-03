#!/bin/bash

script_dir=$(dirname -- "$(readlink -nf $0)")
source "$script_dir/header.sh"
validate_macos

SUPPORT_DIR="$HOME/Library/Application Support/VivadoContainer"

# -- Check if container is installed ------------------------------------------
if ! which container &> /dev/null; then
    f_echo "Apple container CLI is not installed. Either:"
    f_echo "- Download it from https://github.com/apple/container"
    f_echo "- or install it using Homebrew: brew install container"
    exit 1
fi

# -- Check if the image was built --------------------------------------------
if ! container image ls 2>/dev/null | grep -q  "x64-linux"; then
    f_echo "Container image 'x64-linux' not found."
    f_echo "Something went wrong during pkg installation. Please re-run the installer."
    exit 1
fi

# -- Check if Vivado was installed --------------------------------------------
if [ ! -d "$SUPPORT_DIR/Xilinx" ]; then
    f_echo "Vivado installation not found."
    f_echo "The pkg installation may not have completed successfully."
    f_echo "Please re-run VivadoContainer.pkg."
    exit 1
fi

# -- Normal launch ------------------------------------------------------------
exec "$script_dir/start_container.sh"
