#!/bin/bash

echo "Updating any module that depends on a update.sh script"

DIR=$(dirname "$(readlink -f "$0")")

while read -d '' -r file; do
    echo "update script found: $file"
    bash $file 
done < <( find $DIR -maxdepth 2 -name "update.sh" -print0 )
