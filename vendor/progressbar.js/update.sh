#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating progressbar.js from this node modules"

cp -av $NODE_MODULES/progressbar.js/dist/progressbar.min.js $DIR
