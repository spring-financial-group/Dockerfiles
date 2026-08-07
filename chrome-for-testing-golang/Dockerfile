FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:1.26.5 AS golang

FROM jx3mqubebuild.azurecr.io/spring-financial-group/chrome-for-testing:latest

COPY --from=golang /usr/local/go /usr/local/go
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    make \
 && rm -rf /var/lib/apt/lists/*

# Match the official golang image defaults.
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

RUN mkdir -p "$GOPATH"/{src,pkg,bin}
WORKDIR $GOPATH
