FROM jx3mqubebuild.azurecr.io/docker-io/library/python:3.14-slim-trixie AS builder

ARG DOCKSEC_VERSION=2026.7.5
ARG TRIVY_VERSION=0.73.0
ARG TRIVY_SHA256=2edd39da482bb4e9831962487b68f68e3928ec3137794757f54d00383d79547b
ARG HADOLINT_VERSION=2.12.0
ARG HADOLINT_SHA256=56de6d5e5ec427e17b74fa48d51271c7fc0d61244bf5c90e828aab8362d55010
ARG DOCKER_VERSION=29.7.1
ARG DOCKER_SHA256=0fcea2a8b4d1b54ccc9010e3451b78504a369d414f37eb3bb79300e1b5c22ce6

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/docksec-venv

ENV PATH="/opt/docksec-venv/bin:${PATH}"

RUN pip install --no-cache-dir \
    "docksec[ai]==${DOCKSEC_VERSION}"

RUN mkdir -p /opt/tools \
    && curl -fsSL \
         "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
         -o /tmp/trivy.tar.gz \
    && echo "${TRIVY_SHA256}  /tmp/trivy.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/trivy.tar.gz -C /opt/tools trivy \
    && rm /tmp/trivy.tar.gz

RUN curl -fsSL \
         "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64" \
         -o /opt/tools/hadolint \
    && echo "${HADOLINT_SHA256}  /opt/tools/hadolint" | sha256sum -c - \
    && chmod +x /opt/tools/hadolint

RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
         -o /tmp/docker.tgz \
    && echo "${DOCKER_SHA256}  /tmp/docker.tgz" | sha256sum -c - \
    && tar xz -C /opt/tools --strip-components=1 docker/docker \
    && rm /tmp/docker.tgz

FROM jx3mqubebuild.azurecr.io/docker-io/library/python:3.14-slim-trixie

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/docksec-venv /opt/docksec-venv
COPY --from=builder /opt/tools/ /usr/local/bin/

ENV PATH="/opt/docksec-venv/bin:/usr/local/bin:${PATH}"
ENV HOME=/tekton/home

WORKDIR /workspace/source
