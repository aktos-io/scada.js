#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
cd $DIR

UPSTREAM="loadingio"
CUSTOM="ceremcem"

REPO=$CUSTOM

../download "https://raw.githubusercontent.com/$REPO/loading-bar/master/dist/loading-bar.min.js" &
../download "https://raw.githubusercontent.com/$REPO/loading-bar/master/dist/loading-bar.min.css" &
wait

