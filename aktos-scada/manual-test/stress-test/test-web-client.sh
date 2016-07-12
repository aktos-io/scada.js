#!/bin/bash 

i=0
while true; do
	echo "trial: $i"
	firefox http://localhost:4000 &> /dev/null & 
	sleep 10
	killall firefox
	i=$(($i+1))
done
