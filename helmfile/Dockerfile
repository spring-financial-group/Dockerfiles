FROM alpine:3.21

RUN apk add --no-cache ca-certificates git bash

RUN wget -nv https://github.com/jenkins-x/docker-credential-acr-env/releases/download/v0.0.4/docker-credential-acr-env_0.0.4_linux_amd64.tar.gz \
    && tar -xzvf docker-credential-acr-env_0.0.4_linux_amd64.tar.gz \
    && mv docker-credential-acr-env /bin/docker-credential-acr-env \
    && chmod +x /bin/docker-credential-acr-env

RUN wget -nv https://get.helm.sh/helm-v4.1.3-linux-amd64.tar.gz \
    && tar -xzvf helm-v4.1.3-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64 helm-v4.1.3-linux-amd64.tar.gz \
    && chmod +x /usr/local/bin/helm

RUN wget -nv https://github.com/helmfile/helmfile/releases/download/v1.4.3/helmfile_1.4.3_linux_amd64.tar.gz \
    && tar -xzvf helmfile_1.4.3_linux_amd64.tar.gz \
    && mv helmfile /usr/local/bin/helmfile \
    && rm -f helmfile_1.4.3_linux_amd64.tar.gz \
    && chmod +x /usr/local/bin/helmfile

CMD ["bash"]
