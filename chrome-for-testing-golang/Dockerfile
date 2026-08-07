FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:1.26.5 AS golang

FROM jx3mqubebuild.azurecr.io/spring-financial-group/chrome-for-testing:latest

COPY --from=golang /usr/local/go /usr/local/go
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    make \
 && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/go/bin:${PATH}"
