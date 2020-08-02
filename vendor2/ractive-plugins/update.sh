#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
cd $DIR

while read -u 10 URL; do
    ../download "${URL}" &
done 10<"$DIR/plugins.txt"
wait 

# rename extensionless files to js
find . -type f ! -name "*.*" -exec mv {} {}.js \; 
