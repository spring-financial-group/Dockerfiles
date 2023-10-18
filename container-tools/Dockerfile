FROM bitnami/kubectl:1.28.2 as kubectl

FROM alpine:3.16
RUN apk add --no-cache ca-certificates curl wget bash git

RUN mkdir /source && cd /source
RUN wget -nv https://github.com/jenkins-x/docker-credential-acr-env/releases/download/v0.0.4/docker-credential-acr-env_0.0.4_linux_amd64.tar.gz \
    && tar -xzvf docker-credential-acr-env_0.0.4_linux_amd64.tar.gz \
    && mv docker-credential-acr-env /bin/docker-credential-acr-env \
    && chmod +x /bin/docker-credential-acr-env

RUN wget -nv https://github.com/sigstore/cosign/releases/download/v2.2.0/cosign-linux-amd64 \
    && mv cosign-linux-amd64 /bin/cosign \
    && chmod +x /bin/cosign

RUN wget -nv https://github.com/google/go-containerregistry/releases/download/v0.16.1/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv crane /bin/crane \
    && chmod +x /bin/crane

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/

CMD ["bash"]
