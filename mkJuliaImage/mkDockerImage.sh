#!/bin/bash
# This scrypt download julia and make docker image automaticaly
# docker run -it --rm myjulia:v0.1 julia forImageTest.jl
docker build -t myjulia:v0.1 .
docker run -it --rm -v "$PWD":/usr/myapp -w /usr/myapp myjulia:v0.1 julia forImageTest.jl
# docker run -it --rm 630a957a637a julia hello.jl

# curl -O https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.0-linux-x86_64.tar.gz
# tar -xvf julia-1.7.0-linux-x86_64.tar.gz
# rm julia-1.7.0-linux-x86_64.tar.gz
# docker build -t tgbot:v0.3 .
# rm -r julia-1.7.0
#docker run -d -p 2000:443 tgbot:v0.3 # If you want to run image
# docker run -it --rm -v "$PWD":/usr/myapp -w /usr/myapp 630a957a637a julia hello.jl
# docker run -it --rm -v "$PWD":/usr/myapp -w /usr/myapp 630a957a637a julia hello.jl
