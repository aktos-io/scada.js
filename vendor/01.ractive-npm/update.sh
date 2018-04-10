#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

cd "$DIR/../.."
#npm i --save ractive@latest
#npm i --save ractive@1.0.0-build-155
npm i --save ractive@1.0.0-build-155

cd $DIR
export NODE_MODULES=$(realpath "$DIR/../../node_modules")
echo "updating ractive from this node modules"

# Create bundle
browserify -t browserify-livescript ractive-npm.ls -o ractive-latest.js

# Create a temporary warning to console
cat <<WARNING > tmp-warning.js
(function (global, factory) {
	typeof exports === 'object' && typeof module !== 'undefined' ? factory() :
	typeof define === 'function' && define.amd ? define(factory) :
	(factory());
}(this, (function () { 'use strict';
    console.warn("-------------------------- IMPORTANT WARNING ---------------------------------------")
    console.warn("RACTIVE IS UPDATED. TEST WEBAPP IF IT CAN BE VIEWED CORRECTLY ON MOBILE/OLD DEVICES.");
    console.warn("Then remove this file.")
    console.warn("-------------------------- /IMPORTANT WARNING ---------------------------------------")
})));
WARNING
