#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating ractive from this node modules"

cd $DIR

download_asset () {
	local addr=$1
	local file=$(basename $addr)
	echo "downloading $file "
	mv $file $file.bak 2> /dev/null 
	wget $addr || exit 5
	rm $file.bak 2> /dev/null
	echo "$file downloaded"
}

download_asset https://raw.githubusercontent.com/loadingio/loading-bar/master/dist/loading-bar.js
download_asset https://raw.githubusercontent.com/loadingio/loading-bar/master/dist/loading-bar.css