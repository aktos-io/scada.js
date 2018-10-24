#!/bin/bash 
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source
# end of bash boilerplate

[[ -z ${1:-} ]] && { echo "first parameter must be the webapp name"; exit 1; }

set +e

pidfile=$(mktemp)
pid=
compile(){
    while :; do
        gulp --webapp "$1" &
        pid=$!
        echo $pid > $pidfile
        wait
        echo "restarting gulp..."
        sleep 1
    done
}

restart(){
    while :;do
        sleep 24h # actually it seems no need for restart function at all
        echo "Restarting gulp"
        pid=$(cat $pidfile)
        if [[ ! -z $pid ]]; then
            kill $pid
            echo > $pidfile
        fi
    done
}

compile $1 &
restart
wait
