FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:1.26 AS golang

FROM jx3mqubebuild.azurecr.io/spring-financial-group/chrome-for-testing:latest
COPY --from=golang /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"
