#!/bin/bash 


mkdir -p ./tmp/lsc-watch

echo "Compiling Coffee-script to Javascript..."
lsc -o ./tmp/lsc-watch/ -cw server.ls

echo "Removing temporary directory..."
rm ./tmp -r 

echo "All done, exiting..."
