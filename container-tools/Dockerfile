FROM jx3mqubebuild.azurecr.io/docker-io/alpine/kubectl:1.35.6 AS kubectl

FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:3.24
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ca-certificates curl wget bash git make yq jq github-cli zip

RUN mkdir /source && cd /source
RUN wget -nv https://github.com/spring-financial-group/docker-credential-acr-env/releases/download/v0.0.76-alpha/docker-credential-acr-env \
    && mv docker-credential-acr-env /bin/docker-credential-acr-env \
    && chmod +x /bin/docker-credential-acr-env

RUN wget -nv https://github.com/sigstore/cosign/releases/download/v3.1.2/cosign-linux-amd64 \
    && mv cosign-linux-amd64 /bin/cosign \
    && chmod +x /bin/cosign

RUN wget -nv https://github.com/google/go-containerregistry/releases/download/v0.21.7/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv crane /bin/crane \
    && chmod +x /bin/crane

CMD ["bash"]
