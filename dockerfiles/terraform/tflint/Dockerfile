FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:3.21

# renovate: datasource=github-releases depName=terraform-linters/tflint extractVersion=^v(?<version>.*)$
ARG TFLINT_VERSION=0.64.0

RUN apk update && \
    apk upgrade && \
    apk add curl jq bash \
    && cd /tmp \
    && curl -fsSLO https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && curl -fsSLO https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/checksums.txt \
    && grep ' tflint_linux_amd64.zip$' checksums.txt | sha256sum -c - \
    && unzip tflint_linux_amd64.zip -d /usr/local/bin \
    && rm tflint_linux_amd64.zip checksums.txt \
    && tflint --version

CMD ["bash"]
