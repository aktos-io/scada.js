#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
SRC=~/src-3rd/Semantic-UI

echo "Updating SemanticUI from $SRC"

if [ ! -d $SRC ]; then
    echo "ERROR: No source folder is found, clone SemanticUI to $SRC first"
    exit
fi

cd $DIR

rsync -av  $SRC/Semantic-UI/dist .
rsync -av --remove-source-files dist/themes ../../src/client/assets/
rm -r dist/themes

echo "removing uncompressed javascript and css files..."
IFS=$'\n'
for f in $(find . -name '*.js' -or -name '*.css'); do
    if [[ ${f: -7} == ".min.js" ]]; then
        echo "skipping min.js"
        continue
    fi
    if [[ ${f: -8} == ".min.css" ]]; then
        echo "skipping min.css"
        continue
    fi
    rm $f
done
