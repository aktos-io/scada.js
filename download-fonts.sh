#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")

# Found in semantic.ui/site.min.css: @import url(https://fonts.googleapis.com/css?family=Lato:400,700,400italic,700italic&subset=latin)
# Changed with: ????????????

mkdir -p $DIR/vendor2/02.semantic-ui/assets/fonts
cd $DIR/vendor2/02.semantic-ui/assets/fonts
curl -L -o f.zip "https://gwfh.mranftl.com/api/fonts/lato?download=zip&subsets=latin&variants=400,700,400italic,700italic" \
    && unzip -o f.zip && rm f.zip