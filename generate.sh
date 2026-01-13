#!/bin/bash

set -e

rm -f output/*
rdmd main.d $1 $2 $3
rm output.gif
ffmpeg -framerate 10 -pattern_type glob -i "output/output*.ppm" output.gif