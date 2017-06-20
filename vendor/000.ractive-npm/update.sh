#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating ractive from this node modules"

cd $DIR
browserify -t browserify-livescript ractive-npm.ls -o ractive-latest.js

#echo "downloading polyfills.js to support older browsers"
#mv polyfills.js polyfills.js.bak
#wget https://cdn.jsdelivr.net/npm/ractive@latest/polyfills.js || exit 5
#rm polyfills.js.bak

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
