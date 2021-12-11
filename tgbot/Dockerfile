FROM ubuntu:latest
MAINTAINER rosenrot
LABEL version="Beta 0.1"
COPY ./* /home/
COPY julia-1.7.0 /home/julia-1.7.0
EXPOSE 443
WORKDIR /home/
ENTRYPOINT ["./julia-1.7.0/bin/julia", "./tgbot.jl"]
