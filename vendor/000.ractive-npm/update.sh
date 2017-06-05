#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating ractive from this node modules"

cd $DIR
browserify -t browserify-livescript ractive-npm.ls -o ractive-latest.js
