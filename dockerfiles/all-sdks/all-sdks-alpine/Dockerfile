# We've added python/uv for completion
# However, we recommend using Debian
ARG GO_VERSION=1.27.3
ARG JAVA_VERSION=17
ARG DOTNET_VERSION=10.0
ARG NODE_VERSION=24.22.0
ARG NPM_VERSION=11.10.0
ARG GRADLE_VERSION=8.13

# These should be pinned to an SHA and updated by renovatebot
FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:${GO_VERSION}-alpine AS go-builder

FROM jx3mqubebuild.azurecr.io/docker-io/library/eclipse-temurin:${JAVA_VERSION}-jdk-alpine AS java-builder

FROM jx3mqubebuild.azurecr.io/mcr-microsoft-com/dotnet/sdk:${DOTNET_VERSION}-alpine AS dotnet-builder

FROM jx3mqubebuild.azurecr.io/ghcr-io/astral-sh/uv:python3.10-alpine

# Copy the compiled toolchains from the builder stages FIRST
COPY --from=go-builder /usr/local/go /usr/local/go
COPY --from=java-builder /opt/java/openjdk /opt/java/openjdk
COPY --from=dotnet-builder /usr/share/dotnet /usr/share/dotnet

RUN apk update && apk add --no-cache \
    libstdc++ \
    libgcc \
    zlib \
    tzdata \
    icu-libs \
    build-base \
    python3-dev \
    musl-dev \
    linux-headers \
    libffi-dev \
    openssl-dev \
    freetds-dev \
    openblas-dev \
    gfortran \
    jpeg-dev \
    zlib-dev \
    freetype-dev \
    tiff-dev \
    wget \
    unzip

# Re-declare remaining ARGs before using them in ENVs
ARG NODE_VERSION
ARG NPM_VERSION
ARG GRADLE_VERSION

ENV JAVA_HOME=/opt/java/openjdk \
    DOTNET_ROOT=/usr/share/dotnet \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0 \
    NPM_VERSION=${NPM_VERSION} \
    GRADLE_VERSION=${GRADLE_VERSION} \
    PATH="/opt/java/openjdk/bin:/usr/share/dotnet:/usr/local/go/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin:${PATH}"

RUN wget --https-only --max-redirect=0 -qO /tmp/node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64-musl.tar.xz" \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && npm install -g "npm@${NPM_VERSION}" \
    && wget --https-only --max-redirect=2 -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip \
    && rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

CMD ["/bin/sh"]
