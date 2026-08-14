ARG GO_VERSION=1.26.6
ARG ALPINE_VERSION=3.24
ARG GOBUILDCACHE_VERSION=1.7.0

ARG TARGETARCH=amd64
ARG GOCACHEPROG=$GOPATH/bin/gobuildcache
ARG GOLANGCI_LINT_CACHEPROG=$GOPATH/bin/gobuildcache

FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:${GO_VERSION}-alpine${ALPINE_VERSION}


# update alpine, install curl & make, download golangci-lint & gobuildcache
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache curl make && \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh \
        | sh -s -- -b "$(go env GOPATH)/bin" v2.12.2 && \
    curl -sSfL "https://github.com/richardartoul/gobuildcache/releases/download/v${GOBUILDCACHE_VERSION}/gobuildcache_${GOBUILDCACHE_VERSION}_linux_${TARGETARCH}.tar.gz" \
        | tar -xz -C "$(go env GOPATH)/bin" gobuildcache