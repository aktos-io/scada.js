#!/bin/bash

SCADA="../.."
DIST="$SCADA/node_modules/bootstrap/dist"

CSS="$DIST/css"
JS="$DIST/js"

echo "copying css files..."
cp $CSS/*.min.css* .

echo "copying js files..."
cp $JS/*.min.js* .

echo "copying fonts..."
ls $DIST/fonts/*
cp $DIST/fonts/* $SCADA/src/client/assets/fonts
