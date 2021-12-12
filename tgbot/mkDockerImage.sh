#!/bin/bash
# This scrypt download julia and make docker image automaticaly
curl -O https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.0-linux-x86_64.tar.gz
tar -xvf julia-1.7.0-linux-x86_64.tar.gz
rm julia-1.7.0-linux-x86_64.tar.gz
docker build -t tgbot:v0.2 .
rm -r julia-1.7.0
docker run -d -p 2000:443 tgbot:v0.2 # If you want to run image
