#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
cd $DIR

download(){
    local URL=$1
    local FILE=$(basename $URL)

    echo "updating $FILE"
    mv ${FILE} ${FILE}.bak 
    wget ${URL} || exit 5
    rm ${FILE}.bak
}

download "https://raw.githubusercontent.com/ceremcem/JsBarcode/master/dist/JsBarcode.all.min.js"
