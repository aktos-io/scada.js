#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating babel-polyfill from this node modules"

cd $DIR
browserify -t browserify-livescript polyfill.ls -o polyfill.js
