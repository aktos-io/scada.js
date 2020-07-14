#!/bin/bash
#
# Usage:
#
#     ./update.sh
#
set -eu -o pipefail
set_dir(){ _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; set_dir
safe_source () { source $1; set_dir; }
# end of bash boilerplate

if [[ ${1:-} = "list" ]]; then
    npm view ractive
    exit 0
fi

#RACTIVE_VERSION=${1:-"latest"}
#echo "Updating Ractive to: $RACTIVE_VERSION"
#
#cd "$_dir/../.."
#npm i --save ractive@$RACTIVE_VERSION
#
#cd $_dir
export NODE_MODULES=$(realpath "$_dir/../../node_modules")
#cp $NODE_MODULES/ractive/ractive.min.js .

# Create "extras" bundle
browserify -t browserify-livescript z_ractive_extras.ls -o z_ractive_extras.js
