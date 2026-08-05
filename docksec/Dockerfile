FROM jx3mqubebuild.azurecr.io/docker-io/library/python:3.14-slim-trixie AS builder

ARG DOCKSEC_VERSION=2026.7.5

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        make \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/docksec-venv

ENV PATH="/opt/docksec-venv/bin:${PATH}"

RUN pip install --no-cache-dir \
    "docksec[ai]==${DOCKSEC_VERSION}"


FROM jx3mqubebuild.azurecr.io/docker-io/library/python:3.14-slim-trixie

ARG TRIVY_VERSION=0.73.0
ARG HADOLINT_VERSION=2.12.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        libxcb1 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libgl1 \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/docksec-venv /opt/docksec-venv

ENV PATH="/opt/docksec-venv/bin:/usr/local/bin:${PATH}"
ENV HOME=/tekton/home

RUN curl -fsSL \
      "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
      -o /tmp/trivy.tar.gz \
    && tar -xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy \
    && rm /tmp/trivy.tar.gz

RUN curl -fsSL \
      "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64" \
      -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint

WORKDIR /workspace/source
