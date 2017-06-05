#!/bin/bash

echo "updating jquery from this node modules"

browserify -t browserify-livescript jquery-npm.ls -o jquery-latest.js
