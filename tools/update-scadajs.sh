#!/bin/bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCADAJS_ROOT="$CURR_DIR/.."

cd "$SCADAJS_ROOT"

git pull
git submodule update --init --recursive
