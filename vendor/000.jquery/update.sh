#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

export NODE_MODULES="$DIR/../../node_modules"
echo "updating jquery from this node modules"

cd $DIR

browserify -t browserify-livescript jquery-npm.ls -o jquery-latest.js
