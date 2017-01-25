#!/bin/bash

echo "updating ractive from this node modules"

browserify -t browserify-livescript ractive-npm.ls -o ractive-latest.js
