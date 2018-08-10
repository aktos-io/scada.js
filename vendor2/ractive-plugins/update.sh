#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
cd $DIR

while read -u 10 URL; do
    FILE="$(basename $URL).js"
    echo "updating $FILE"
    mv ${FILE} ${FILE}.bak 2> /dev/null
    wget ${URL} -O ${FILE} || exit 5
    rm ${FILE}.bak 2> /dev/null
done 10<"$DIR/plugins.txt"
