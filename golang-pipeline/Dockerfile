ARG GO_VERSION=1.26.6
ARG DEB_DISTRO=trixie

FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:${GO_VERSION}-trixie

ARG GOBUILDCACHE_VERSION=1.7.0
ARG GOLANGCILINT_VERSION=v2.12.2
ARG TARGETARCH=amd64
ARG GOCACHEPROG=$GOPATH/bin/gobuildcache
ARG GOLANGCI_LINT_CACHEPROG=$GOPATH/bin/gobuildcache


# update debian, download golangci-lint & gobuildcache
# (git, curl & make are already present in the golang base image)
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get purge -y --auto-remove subversion mercurial && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh \
        | sh -s -- -b "$(go env GOPATH)/bin" ${GOLANGCILINT_VERSION} && \
    curl -sSfL "https://github.com/richardartoul/gobuildcache/releases/download/v${GOBUILDCACHE_VERSION}/gobuildcache_${GOBUILDCACHE_VERSION}_linux_${TARGETARCH}.tar.gz" \
        | tar -xz -C "$(go env GOPATH)/bin" gobuildcache