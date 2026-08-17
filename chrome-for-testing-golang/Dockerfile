ARG GO_VERSION=1.26.6

FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:1.26.6 AS golang

FROM jx3mqubebuild.azurecr.io/spring-financial-group/chrome-for-testing:latest

# Match the official golang image defaults.
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

ARG GOBUILDCACHE_VERSION=1.7.0
ARG GOLANGCILINT_VERSION=v2.12.2
ARG TARGETARCH=amd64


COPY --from=golang /usr/local/go /usr/local/go
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    make \
 && rm -rf /var/lib/apt/lists/* \
 && curl -sSfL "https://github.com/richardartoul/gobuildcache/releases/download/v${GOBUILDCACHE_VERSION}/gobuildcache_${GOBUILDCACHE_VERSION}_linux_${TARGETARCH}.tar.gz" \
         | tar -xz -C "${}GOPATH}/bin" gobuildcache

RUN mkdir -p "$GOPATH"/{src,pkg,bin}
WORKDIR $GOPATH
