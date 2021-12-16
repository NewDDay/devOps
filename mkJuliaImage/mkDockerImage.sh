#!/bin/bash

docker build -t myjulia:v0.1 . # You can change version
docker run -it --rm -v "$PWD":/usr/myapp -w /usr/myapp myjulia:v0.1 julia forImageTest.jl
