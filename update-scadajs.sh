#!/bin/bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$CURR_DIR/.."

#git submodule foreach --recursive git submodule update --init
git pull origin master 
git submodule foreach git pull origin master 
