#!/bin/bash

set -e

rm -f output/*
rdmd -O -boundscheck=off -release main.d $1 $2 $3
rm -f output.gif
ffmpeg -framerate 10 -pattern_type glob -i "output/output*.ppm" output.gif