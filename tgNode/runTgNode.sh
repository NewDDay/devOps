docker run -d -p 1999:1999 -v "/home/rosenrot/devOps/":/home/rosenrot/devOps/ -w /home/rosenrot/devOps/ --restart unless-stopped myjulia:v0.1 julia ./tgNode/tgNode.jl
