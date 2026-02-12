FROM jx3mqubebuild.azurecr.io/docker-io/library/node:24.13

# Setting npm version on it's own line to avoid issues with it updating itself
RUN npm install -g npm@11.6.10
RUN npm install -g \
    @angular/cli@20.3 \
    @angular/compiler-cli@20.3 \
    typescript@5.8 && \
    apt-get update && \
    apt-get install -y \
        libnss3 \
        libnspr4 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libcups2 \
        libdrm2 \
        libxkbcommon0 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxrandr2 \
        libgbm1 \
        libasound2

CMD ["bash"]
