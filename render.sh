#!/bin/bash

echo Starting render
date

docker run     -it     --rm     -v $(pwd):/openscad     -u $(id -u ${USER})   openscad/openscad:dev openscad -o belt_buckle/buckle.stl belt_buckle/buckle.scad

echo Done render
date

