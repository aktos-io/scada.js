#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
cd $DIR

../download "https://raw.githubusercontent.com/loadingio/loading-bar/master/dist/loading-bar.js" &
../download "https://raw.githubusercontent.com/loadingio/loading-bar/master/dist/loading-bar.css" &
wait

