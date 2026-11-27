FROM jx3mqubebuild.azurecr.io/docker-io/library/node:24-trixie-slim
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g npm@11.21.3
