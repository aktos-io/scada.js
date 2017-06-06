#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating progressbar.js from this node modules"

cp -av $NODE_MODULES/socket.io-client/dist/socket.io.js $DIR
