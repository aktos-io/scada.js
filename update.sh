#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

git submodule update --recursive --init
cd $DIR
git submodule update --recursive --init

