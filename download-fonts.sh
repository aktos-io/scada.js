#!/bin/bash
set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

DIR=$(dirname "$(readlink -f "$0")")

# See API documentation: https://github.com/majodev/google-webfonts-helper#json-api

# Found in semantic.ui/site.min.css: @import url(https://fonts.googleapis.com/css?family=Lato:400,700,400italic,700italic&subset=latin)
# Remove this "@import url(...);" part as it is included by $fonts_file.
semanticui_dir=$DIR/vendor/02.semantic-ui/
fonts_dir="$semanticui_dir/assets/fonts"
fonts_file="fonts-of-site.min.css"

cd "$semanticui_dir"
if [ -f $fonts_file ]; then 
    echo 
    printf "${YELLOW}WARNING: $fonts_file exists, not downloading again. Remove it if you like to re-download.${NC}\n"
    echo 
else 
    curl -o $fonts_file "https://fonts.googleapis.com/css?family=Lato:400,700,400italic,700italic&subset=latin"
fi
mkdir -p $fonts_dir
cd $fonts_dir
# replaced 400 with regular
# replaced 400italic with italic
curl -L -o f.zip "https://gwfh.mranftl.com/api/fonts/lato?download=zip&subsets=latin&variants=regular,italic,700,700italic" \
    && unzip -o f.zip && rm f.zip

printf "${GREEN}Edit $fonts_file accordingly.${NC}\n"