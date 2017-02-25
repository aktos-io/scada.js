#!/bin/bash

rsync -av  ~/dev-3rd/Semantic-UI/dist ./
rsync -av --remove-source-files dist/themes ../../src/client/assets/css/

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
