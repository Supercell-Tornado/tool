#!/bin/bash
imagetype=eps
ncl ./drawskewt_10.ncl 2>&1 | tee ./log
ps2raster -Tg -A ./*.$imagetype
mkdir -p ./image
mv *.$imagetype ./image/
mv *.png        ./image/
exit

