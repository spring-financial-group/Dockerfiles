FROM jx3mqubebuild.azurecr.io/docker-io/library/node:24.19-alpine

# renovate: datasource=npm depName=npm
ARG NPM_VERSION=11.19.0
# renovate: datasource=npm depName=@angular/cli
ARG ANGULAR_VERSION=20.3
# renovate: datasource=npm depName=typescript
ARG TYPESCRIPT_VERSION=5.8

RUN npm install -g "npm@${NPM_VERSION}" "@angular/cli@${ANGULAR_VERSION}" "@angular/compiler-cli@${ANGULAR_VERSION}" "typescript@${TYPESCRIPT_VERSION}"

CMD ["/bin/sh"]
