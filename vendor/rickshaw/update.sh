#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating c3js from this node modules"

cp -av $NODE_MODULES/rickshaw/*.min.css $DIR
