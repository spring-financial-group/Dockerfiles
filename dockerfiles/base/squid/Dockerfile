FROM jx3mqubebuild.azurecr.io/docker-io/ubuntu/squid:latest
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
