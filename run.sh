#! /bin/bash
mkdir -p out
docker build -t clfs . && docker run -it --rm -v "$(pwd)/out:/out" clfs cp -rv /clfs/out/clfs-arm.tar.bz2 /out
