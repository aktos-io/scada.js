#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
cd $DIR

URL="https://raw.githubusercontent.com/ceremcem/JsBarcode/master/dist/JsBarcode.all.min.js"
FILE=$(basename $URL)

echo "updating $FILE"
mv ${FILE} ${FILE}.bak 
wget ${URL} || exit 5
rm ${FILE}.bak
