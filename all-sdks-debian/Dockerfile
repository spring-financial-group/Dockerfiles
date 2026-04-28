ARG GO_VERSION=1.24.4
ARG JAVA_VERSION=17
ARG DOTNET_VERSION=8.0
ARG NODE_VERSION=24.13.0
ARG NPM_VERSION=11.10.0
ARG GRADLE_VERSION=8.13

# These should be pinned to an SHA and updated by renovatebot
FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:${GO_VERSION}-bookworm AS go-builder

FROM jx3mqubebuild.azurecr.io/docker-io/library/eclipse-temurin:${JAVA_VERSION}-jdk-jammy AS java-builder

FROM jx3mqubebuild.azurecr.io/mcr-microsoft-com/dotnet/sdk:${DOTNET_VERSION} AS dotnet-builder

FROM jx3mqubebuild.azurecr.io/ghcr-io/astral-sh/uv:0.11.7-python3.10-trixie-slim

# Re-declare ARGs for use in this stage
ARG NODE_VERSION
ARG NPM_VERSION
ARG GRADLE_VERSION
ARG JAVA_VERSION

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=go-builder /usr/local/go /usr/local/go
COPY --from=java-builder /opt/java/openjdk /opt/java/openjdk
COPY --from=dotnet-builder /usr/share/dotnet /usr/share/dotnet

# wget, ca-certificates and unzip needed for image
# All others are needed for python as we use a slim image
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        unzip \
        xz-utils \
        zstd \
        gcc \
        g++ \
        make \
        pkg-config \
        linux-headers-amd64 \
        libffi-dev \
        libssl-dev \
        libicu-dev \
        zlib1g-dev \
        freetds-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libwebp-dev \
        libfreetype6-dev \
        libgomp1 \
        libxml2-dev \
        libxslt1-dev

# NodeJS
RUN wget --https-only --max-redirect=0 -qO /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && npm install -g "npm@${NPM_VERSION}" \
    # Gradle
    && wget --https-only --max-redirect=2 -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -P /tmp \
    && unzip -d /opt/gradle "/tmp/gradle-${GRADLE_VERSION}-bin.zip" \
    && rm "/tmp/gradle-${GRADLE_VERSION}-bin.zip"

ENV JAVA_HOME="/opt/java/openjdk" \
    DOTNET_ROOT="/usr/share/dotnet" \
    PATH="${PATH}:/usr/local/go/bin:/usr/share/dotnet:/opt/java/openjdk/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin"

CMD ["/usr/bin/bash"]
