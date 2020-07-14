#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")

NODE_MODULES="$DIR/../../node_modules"
echo "updating noUiSlider from this node modules"

cp -av $NODE_MODULES//nouislider/distribute/nouislider.min.css $DIR
