#!/bin/bash
#
# Usage:
#
#     ./update.sh [0.10.2]
#

DIR=$(dirname "$(readlink -f "$0")")

cd "$DIR/../.."
RACTIVE_VERSION=${1:-"latest"}

echo "Updating Ractive to: $RACTIVE_VERSION"

npm i --save ractive@$RACTIVE_VERSION

cd $DIR
export NODE_MODULES=$(realpath "$DIR/../../node_modules")
echo "updating ractive from this node modules"

# Create bundle
browserify -t browserify-livescript ractive-npm.ls -o ractive-latest.js
