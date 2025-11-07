FROM alpine/kubectl:1.34.1 AS kubectl
#RUN apk upgrade --no-cache && apk add --no-cache curl
#RUN curl -LO "https://dl.k8s.io/release/v1.34.1/bin/linux/amd64/kubectl" \
#    && chmod +x kubectl

FROM alpine:3.16
RUN apk upgrade --no-cache && apk add --no-cache ca-certificates curl wget bash git make yq jq github-cli

RUN mkdir /source && cd /source
RUN wget -nv https://github.com/spring-financial-group/docker-credential-acr-env-jx/releases/download/0.1.0/docker-credential-acr-env_0.1.0_linux_amd64.tar.gz \
    && tar -xzvf docker-credential-acr-env_0.1.0_linux_amd64.tar.gz \
    && mv docker-credential-acr-env /bin/docker-credential-acr-env \
    && chmod +x /bin/docker-credential-acr-env

RUN wget -nv https://github.com/sigstore/cosign/releases/download/v3.0.2/cosign-linux-amd64 \
    && mv cosign-linux-amd64 /bin/cosign \
    && chmod +x /bin/cosign

RUN wget -nv https://github.com/google/go-containerregistry/releases/download/v0.20.6/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv crane /bin/crane \
    && chmod +x /bin/crane

#COPY --from=kubectl /kubectl /usr/local/bin/kubectl
CMD ["bash"]