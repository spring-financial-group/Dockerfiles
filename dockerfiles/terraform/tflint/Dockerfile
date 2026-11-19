FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:3.24

ARG TFLINT_VERSION=v0.64.0

RUN apk update && \
    apk upgrade && \
    apk add curl jq bash \
    && cd /tmp \
    && curl -fsSLO https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && curl -fsSLO https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/checksums.txt \
    && grep ' tflint_linux_amd64.zip$' checksums.txt | sha256sum -c - \
    && unzip tflint_linux_amd64.zip -d /usr/local/bin \
    && rm tflint_linux_amd64.zip checksums.txt \
    && tflint --version

CMD ["bash"]
