#!/bin/bash
# Watch command - trivial utility for when you're on AIX...
# usage: watch.sh <your_command> <sleep_duration>

if [[ "$1x" == "x" || "$2x" == "x" ]]; then
    echo 'Usage: watch.sh <your command> <sleep duration>'
    exit 1
fi

while :; 
do 
  $1
  sleep $2
done
