FROM bitnami/kubectl:1.27.6 as kubectl

FROM golang:1.18 as golang
RUN git clone https://github.com/chrismellard/docker-credential-acr-env.git \
    && cd ./docker-credential-acr-env \
    && make build

FROM alpine:3.16
RUN apk add --no-cache ca-certificates curl wget bash git

RUN mkdir /source && cd /source \
    && wget -nv https://github.com/spring-financial-group/docker-credential-acr-env/releases/download/v0.0.7/docker-credential-acr-env \
    && wget -nv https://github.com/sigstore/cosign/releases/download/v2.2.0/cosign-linux-amd64 \
    && wget -nv https://github.com/google/go-containerregistry/releases/download/v0.16.1/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv cosign-linux-amd64 cosign && mv cosign docker-credential-acr-env crane -t /bin \
    && chmod +x /bin/cosign /bin/docker-credential-acr-env /bin/crane

COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/
COPY --from=golang /go/docker-credential-acr-env/build/docker-credential-acr-env /usr/local/bin/
CMD ["bash"]
