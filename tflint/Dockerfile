FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:3.21

RUN apk update && \
    apk upgrade && \
    apk add curl jq bash \
    && curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

CMD ["bash"]
