#!/bin/bash 
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

[[ -z ${1:-} ]] && { echo "first parameter must be the webapp name"; exit 1; }

set +e
while :; do
    gulp --webapp "$1"
    echo "restarting gulp..."
    sleep 1
done
