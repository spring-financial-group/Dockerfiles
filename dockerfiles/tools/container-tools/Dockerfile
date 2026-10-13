FROM jx3mqubebuild.azurecr.io/docker-io/bitnamilegacy/kubectl:1.32 AS kubectl

FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:3.16

# renovate: datasource=github-releases depName=jenkins-x/docker-credential-acr-env extractVersion=^v(?<version>.*)$
ARG ACR_ENV_VERSION=0.0.4
# renovate: datasource=github-releases depName=sigstore/cosign extractVersion=^v(?<version>.*)$
ARG COSIGN_VERSION=2.3.0
# renovate: datasource=github-releases depName=google/go-containerregistry extractVersion=^v(?<version>.*)$
ARG CRANE_VERSION=0.16.1

RUN apk add --no-cache ca-certificates curl wget bash git make yq jq github-cli zip

RUN mkdir /source && cd /source
RUN wget -nv https://github.com/jenkins-x/docker-credential-acr-env/releases/download/v${ACR_ENV_VERSION}/docker-credential-acr-env_${ACR_ENV_VERSION}_linux_amd64.tar.gz \
    && tar -xzvf docker-credential-acr-env_${ACR_ENV_VERSION}_linux_amd64.tar.gz \
    && mv docker-credential-acr-env /bin/docker-credential-acr-env \
    && chmod +x /bin/docker-credential-acr-env

RUN wget -nv https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64 \
    && mv cosign-linux-amd64 /bin/cosign \
    && chmod +x /bin/cosign

RUN wget -nv https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv crane /bin/crane \
    && chmod +x /bin/crane

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/
CMD ["bash"]
