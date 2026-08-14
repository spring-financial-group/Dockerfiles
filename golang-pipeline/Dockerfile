FROM jx3mqubebuild.azurecr.io/dhi-io/golang:1.26-alpine3.24

ARG TARGETARCH=amd64
ARG GOBUILDCACHE_VERSION=1.7.0
ARG GOCACHEPROG=$GOPATH/bin/gobuildcache
ARG GOLANGCI_LINT_CACHEPROG=$GOPATH/bin/gobuildcache

# Install golangci-lint v2.12.2 using the project's official install script.
# Binary lands in $GOPATH/bin (/go/bin), which is already on PATH in the base image.
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh \
    | sh -s -- -b "$(go env GOPATH)/bin" v2.12.2

# Install gobuildcache v1.7.0 from the prebuilt release tarball.
# Binary lands in $GOPATH/bin (/go/bin), which is already on PATH in the base image.
RUN curl -sSfL "https://github.com/richardartoul/gobuildcache/releases/download/v${GOBUILDCACHE_VERSION}/gobuildcache_${GOBUILDCACHE_VERSION}_linux_${TARGETARCH}.tar.gz" \
    | tar -xz -C "$(go env GOPATH)/bin" gobuildcache