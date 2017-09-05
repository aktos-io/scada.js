#!/bin/bash
CURR_FILE="${BASH_SOURCE[0]}"
CURR_DIR="$( cd "$( dirname "$CURR_FILE" )" && pwd )"
SCADA_ROOT="$CURR_DIR/.."

WEBAPP="$1"

if [ "$1" == "" ]; then
    cat <<HELP

    usage:

        $(basename $0) your-webapp

HELP
    exit
fi

$CURR_DIR/node_modules/.bin/electron $CURR_DIR/main.js --webapp $WEBAPP
