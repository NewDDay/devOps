docker run -d -p 1999:1999 -v "$PWD":/home -w /home --restart unless-stopped myjulia:v0.1 julia tgNode.jl
