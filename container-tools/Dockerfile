FROM bitnami/kubectl:1.27 as kubectl

FROM alpine:3.16
RUN apk add --no-cache ca-certificates curl wget bash git

RUN mkdir /source && cd /source \
    && wget https://github.com/spring-financial-group/docker-credential-acr-env/releases/download/v0.0.7/docker-credential-acr-env \
    && wget https://github.com/sigstore/cosign/releases/download/v1.9.0/cosign-linux-amd64 \
    && wget https://github.com/google/go-containerregistry/releases/download/v0.14.0/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv cosign-linux-amd64 cosign && mv cosign docker-credential-acr-env crane -t /bin \
    && chmod +x /bin/cosign /bin/docker-credential-acr-env /bin/crane

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/

CMD ["bash"]
