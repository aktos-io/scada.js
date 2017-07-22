#!/bin/bash 
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_NAME=$1
[[ $PROJECT_NAME ]] || { echo "Project name (first parameter) can not be empty."; exit 5; }

BUILD_DIR="$DIR/../build"
RAM_DIR="/dev/shm/${PROJECT_NAME}_build"

echo "Creating symling for ${BUILD_DIR} in $RAM_DIR"
rm -r $RAM_DIR 2> /dev/null
mkdir -p $RAM_DIR
rm -r $BUILD_DIR 2> /dev/null
ln -s $RAM_DIR $BUILD_DIR
