#!/bin/bash
CURR_FILE="${BASH_SOURCE[0]}"
CURR_DIR="$( cd "$( dirname "$CURR_FILE" )" && pwd )"
SCADA_ROOT="$CURR_DIR/../../.."

cd $CURR_DIR

$SCADA_ROOT/node_modules/.bin/electron $CURR_DIR/main.js
