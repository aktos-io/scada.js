#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
NAME=$(basename $DIR)

echo "updating $NAME from this node modules"

#cp -av $NODE_MODULES/rickshaw/*.min.css $DIR
cp -av $NODE_MODULES/rickshaw/rickshaw.css $DIR
