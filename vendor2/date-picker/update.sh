#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating calendar from this node modules"

cp -av $NODE_MODULES/semantic-ui-calendar/dist/calendar.min.{js,css} $DIR
