#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
SRC=~/src-3rd/Semantic-UI

if [ ! -d $SRC ]; then
    echo "ERROR: No source folder is found, clone SemanticUI to $SRC first"
    exit
fi
echo "Updating SemanticUI from $SRC"
cd $SRC
gulp clean
gulp build

cd $DIR
rm -r dist 2> /dev/null
rm -r assets 2> /dev/null

rsync -av  $SRC/dist .
mkdir assets
mv dist/themes assets

echo "removing uncompressed javascript and css files..."
IFS=$'\n'
for f in $(find dist -name '*.js' -or -name '*.css'); do
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

echo "removing bundled js and css files"
rm dist/semantic.min.*

echo "removing dropdown.min.js regarding to the patched version"
rm dist/components/dropdown.min.js

echo "moving needed parts to vendor/semantic"
d=$(basename $(dirname `readlink -f $0`))
first_stage="../../vendor/$d"

this_dir=$PWD
cd $first_stage
for file in `find .`; do
    [[ -f $file ]] || continue
    [[ -f $this_dir/$file ]] || { echo "seems already moved: $file"; continue; }
    echo "...moving $file"
    mv $this_dir/$file $file
done
