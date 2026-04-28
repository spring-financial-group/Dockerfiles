ARG GO_VERSION=1.23.4
ARG JAVA_VERSION=17
ARG DOTNET_VERSION=8.0
ARG NODE_VERSION=24
ARG NPM_VERSION=10.9.0
ARG GRADLE_VERSION=8.13

# Stage 1: Go Builder
FROM golang:${GO_VERSION}-alpine AS go-builder

# Stage 2: Java Builder
FROM eclipse-temurin:${JAVA_VERSION}-jdk-alpine AS java-builder

# Stage 3: .NET Builder
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION}-alpine AS dotnet-builder

# Stage 4: Your Final Base Image
FROM ghcr.io/astral-sh/uv:python3.10-alpine

# Re-declare NODE_VERSION ARG so we can use it in the apk step
ARG NODE_VERSION

# 2. Copy the compiled toolchains from the builder stages FIRST
COPY --from=go-builder /usr/local/go /usr/local/go
COPY --from=java-builder /opt/java/openjdk /opt/java/openjdk
COPY --from=dotnet-builder /usr/share/dotnet /usr/share/dotnet

# 3. Install underlying system dependencies, Node, and Python Build Tools
# This is the heaviest step. We put it high up so it caches permanently.
RUN apk update && apk add --no-cache \
    "nodejs~=${NODE_VERSION}" \
    npm \
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
ARG NPM_VERSION
ARG GRADLE_VERSION

# 4. Set Environment Variables and PATH
# Moved down here! Now, changing NPM or GRADLE versions won't trigger a massive apk reinstall.
ENV JAVA_HOME=/opt/java/openjdk \
    DOTNET_ROOT=/usr/share/dotnet \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0 \
    NPM_VERSION=${NPM_VERSION} \
    GRADLE_VERSION=${GRADLE_VERSION} \
    PATH="/opt/java/openjdk/bin:/usr/share/dotnet:/usr/local/go/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin:${PATH}"

# 5. Pin NPM version and Install Gradle
RUN npm install -g npm@${NPM_VERSION} \
    && wget --https-only --max-redirect=2 -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip \
    && rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

WORKDIR /app

CMD ["/bin/sh"]
