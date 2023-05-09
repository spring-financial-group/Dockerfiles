FROM ubuntu:20.04 AS builder

RUN apt update && apt install -y ca-certificates curl wget && rm -rf /var/lib/apt/lists/*

RUN mkdir /source && cd /source \
    && wget https://github.com/spring-financial-group/docker-credential-acr-env/releases/download/v0.0.6/docker-credential-acr-env \
    && wget https://github.com/sigstore/cosign/releases/download/v2.0.2/cosign-linux-amd64 \
    && wget https://github.com/google/go-containerregistry/releases/download/v0.14.0/go-containerregistry_Linux_x86_64.tar.gz \
    && tar -xzvf go-containerregistry_Linux_x86_64.tar.gz \
    && mv cosign-linux-amd64 cosign && mv cosign docker-credential-acr-env crane -t /bin \
    && chmod +x /bin/cosign /bin/docker-credential-acr-env /bin/crane

FROM ubuntu:20.04 AS final
COPY --from=builder /bin/cosign /bin/docker-credential-acr-env /bin/crane /bin/

RUN apt update && apt install -y apt-transport-https

CMD ["bash"]
