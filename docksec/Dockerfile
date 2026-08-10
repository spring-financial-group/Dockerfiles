FROM dhi.io/python:3.14-debian-dev AS builder

ARG DOCKSEC_VERSION=2026.7.5
ARG TRIVY_VERSION=0.73.0
ARG HADOLINT_VERSION=2.12.0
ARG DOCKER_VERSION=29.7.1
ARG YQ_VERSION=4.53.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gzip \
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

RUN curl -fsSL "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
         -o /tmp/docker.tgz \
    && tar -xzf /tmp/docker.tgz -C /opt/tools --strip-components=1 docker/docker \
    && rm /tmp/docker.tgz

RUN curl -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64" \
         -o /opt/tools/yq \
    && chmod +x /opt/tools/yq

FROM dhi.io/python:3.14-debian-dev

COPY --from=builder /opt/docksec-venv /opt/docksec-venv
COPY --from=builder /opt/tools/ /usr/local/bin/

ENV PATH="/opt/docksec-venv/bin:/usr/local/bin:${PATH}"
ENV HOME=/tekton/home

WORKDIR /workspace/source
