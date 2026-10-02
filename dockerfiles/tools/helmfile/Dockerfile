FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:3.21

ENV ACR_ENV_VERSION=0.0.4 \
    HELM_VERSION=4.1.3 \
    HELMFILE_VERSION=1.4.4

RUN apk add --no-cache ca-certificates git bash

RUN wget -nv https://github.com/jenkins-x/docker-credential-acr-env/releases/download/v${ACR_ENV_VERSION}/docker-credential-acr-env_${ACR_ENV_VERSION}_linux_amd64.tar.gz \
    && tar -xzvf docker-credential-acr-env_${ACR_ENV_VERSION}_linux_amd64.tar.gz \
    && mv docker-credential-acr-env /bin/docker-credential-acr-env \
    && chmod +x /bin/docker-credential-acr-env

RUN wget -nv https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64 helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && chmod +x /usr/local/bin/helm

RUN wget -nv https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
    && tar -xzvf helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
    && mv helmfile /usr/local/bin/helmfile \
    && rm -f helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
    && chmod +x /usr/local/bin/helmfile

CMD ["bash"]
