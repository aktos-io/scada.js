#!/bin/bash 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR=$(realpath $DIR/../build)
SIZE="12M"
echo "Creating $SIZE of tmpfs on $BUILD_DIR"
sudo mount -t tmpfs -o size=12m tmpfs $BUILD_DIR

