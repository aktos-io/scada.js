#!/bin/bash
set -eu -o pipefail
set_dir(){ _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; set_dir
safe_source () { source $1; set_dir; }
# end of bash boilerplate

export NODE_MODULES="$_dir/../../node_modules"
jq=$NODE_MODULES/jquery/dist/jquery.min.js

#echo "updating jquery from this node modules"
#browserify -t browserify-livescript jquery-npm.ls -o jquery-latest.js
cp -v "$jq" "$_sdir/"
