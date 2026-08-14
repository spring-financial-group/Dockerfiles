ARG GO_VERSION=1.26.6
ARG ALPINE_VERSION=3.24

FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:${GO_VERSION}-alpine${ALPINE_VERSION}

ARG GOBUILDCACHE_VERSION=1.7.0
ARG GOLANGCILINT_VERSION=v2.12.2
ARG TARGETARCH=amd64
ARG GOCACHEPROG=$GOPATH/bin/gobuildcache
ARG GOLANGCI_LINT_CACHEPROG=$GOPATH/bin/gobuildcache


# update alpine, install curl & make, download golangci-lint & gobuildcache
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache git curl make && \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh \
        | sh -s -- -b "$(go env GOPATH)/bin" ${GOLANGCILINT_VERSION} && \
    curl -sSfL "https://github.com/richardartoul/gobuildcache/releases/download/v${GOBUILDCACHE_VERSION}/gobuildcache_${GOBUILDCACHE_VERSION}_linux_${TARGETARCH}.tar.gz" \
        | tar -xz -C "$(go env GOPATH)/bin" gobuildcache