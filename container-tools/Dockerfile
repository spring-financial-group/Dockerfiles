ARG KUBECTL_VERSION=v1.36.4

FROM jx3mqubebuild.azurecr.io/registry-k8s-io/kubectl:${KUBECTL_VERSION} AS kubectl

ARG ALPINE_VERSION=3.24

FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:${ALPINE_VERSION}

ARG ACR_CREDENTIAL_VERSION=v0.76.2
ARG COSIGN_VERSION=v3.1.3
ARG CRANE_VERSION=v0.22.1

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        ca-certificates \
        curl \
        wget \
        bash \
        git \
        make \
        yq \
        jq \
        github-cli \
        zip && \
     mkdir /source &&  \
     cd /source

RUN wget -nv https://github.com/spring-financial-group/docker-credential-acr-env/releases/download/${ACR_CREDENTIAL_VERSION}/docker-credential-acr-env \
    && mv docker-credential-acr-env /bin/docker-credential-acr-env \
    && chmod +x /bin/docker-credential-acr-env

RUN wget -nv https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64 \
    && mv cosign-linux-amd64 /bin/cosign \
    && chmod +x /bin/cosign

RUN wget -nv https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv crane /bin/crane \
    && chmod +x /bin/crane

COPY --from=kubectl /bin/kubectl /usr/local/bin/
CMD ["bash"]
