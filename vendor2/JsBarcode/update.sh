#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
cd $DIR

../download "https://raw.githubusercontent.com/ceremcem/JsBarcode/master/dist/JsBarcode.all.min.js"
