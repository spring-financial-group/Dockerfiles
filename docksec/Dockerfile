FROM jx3mqubebuild.azurecr.io/docker-io/library/python:3.14-slim-trixie AS builder

ARG DOCKSEC_VERSION=2026.7.5
ARG TRIVY_VERSION=0.73.0
ARG HADOLINT_VERSION=2.12.0
ARG DOCKER_VERSION=29.7.1

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
    && tar -xzf /tmp/trivy.tar.gz -C /opt/tools trivy \
    && rm /tmp/trivy.tar.gz

RUN curl -fsSL \
         "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64" \
         -o /opt/tools/hadolint \
    && chmod +x /opt/tools/hadolint

RUN ARCH=$(uname -m) \
    && curl -fsSL "https://download.docker.com/linux/static/stable/${ARCH}/docker-${DOCKER_VERSION}.tgz" \
         | tar xz -C /opt/tools --strip-components=1 docker/docker

FROM jx3mqubebuild.azurecr.io/docker-io/library/python:3.14-slim-trixie

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/docksec-venv /opt/docksec-venv
COPY --from=builder /opt/tools/ /usr/local/bin/

ENV PATH="/opt/docksec-venv/bin:/usr/local/bin:${PATH}"
ENV HOME=/tekton/home

WORKDIR /workspace/source
