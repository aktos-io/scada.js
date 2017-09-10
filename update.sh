#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd $DIR
git pull
git submodule update --recursive --init

