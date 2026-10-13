# Playwright on Alpine is still experimental, so we will use a Debian-based image for now. See https://playwright.dev/docs/intro#running-on-alpine-linux for more information.
FROM jx3mqubebuild.azurecr.io/docker-io/library/node:24.13

# Setting npm version on it's own line to avoid issues with it updating itself
# renovate: datasource=npm depName=npm
ARG NPM_VERSION=11.10.0
# renovate: datasource=npm depName=@angular/cli
ARG ANGULAR_VERSION=20.3
# renovate: datasource=npm depName=typescript
ARG TYPESCRIPT_VERSION=5.8

RUN npm install -g "npm@${NPM_VERSION}"
RUN npm install -g \
    "@angular/cli@${ANGULAR_VERSION}" \
    "@angular/compiler-cli@${ANGULAR_VERSION}" \
    "typescript@${TYPESCRIPT_VERSION}" && \
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
