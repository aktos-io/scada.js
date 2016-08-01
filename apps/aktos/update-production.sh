#!/bin/bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$CURR_DIR"

git pull

cd "$CURR_DIR/../.."
ls -1
sleep 5

git pull
git submodule update --recursive

rm -r build 2> /dev/null
gulp --compile --project=aktos
echo "Copying build/public to __public__"
rm -r __public__ 2> /dev/null
cp -a build/public/ __public__
