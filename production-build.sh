#!/bin/bash 
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

app=${1:-}
if [[ -z $app ]]; then
    echo "Usage: "
    echo "    $(basename $0) your-app-name"
    exit 3
fi
cd $_sdir
gulp --production --webapp $app
