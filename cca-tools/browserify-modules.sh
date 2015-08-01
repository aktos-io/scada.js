#!/bin/bash 

echo "Browserifying modules..."
LIB="./static/ic"
browserify -r $LIB/weblib.js:weblib -o $LIB/weblib-browser.js 
