#!/bin/sh

# Restart the main thread of mjsxj02hl application
killall mjsxj02hl
while killall -0 mjsxj02hl
do
    sleep 1
done
mjsxj02hl &

