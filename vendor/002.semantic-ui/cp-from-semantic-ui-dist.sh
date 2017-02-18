#!/bin/bash 

rsync -a --include '*/' --include '*.min.js' --include '*.min.css' --exclude '*' ~/dev-3rd/Semantic-UI/dist ./