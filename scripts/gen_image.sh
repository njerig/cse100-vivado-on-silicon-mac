#!/bin/bash

# Generate the container image using Apple's container CLI

script_dir=$(dirname -- "$(readlink -nf $0)";)
source "$script_dir/header.sh"
validate_macos

# check if container CLI is installed
if ! which container &> /dev/null
then
    f_echo "You need to install the Apple container CLI first."
    exit 1
fi

# Build the image according to the Dockerfile
f_echo "Building image..."
if ! container build --arch amd64 -t x64-linux "$script_dir"
then
    f_echo "Image generation failed!"
    exit 1
fi

f_echo "The image was successfully generated."
