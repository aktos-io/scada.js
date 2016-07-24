#!/bin/bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$CURR_DIR/.."

ELECTRON_BINARY="$CURR_DIR/../node_modules/.bin/electron"
ELECTRON_APP="$CURR_DIR/../src/electron"

$ELECTRON_BINARY $ELECTRON_APP
