FROM ghcr.io/astral-sh/uv:0.11.7-python3.10-trixie

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Language versions
ENV NODE_VERSION="24.13.0"
ENV GO_VERSION="1.24.4"
ENV DOTNET_VERSION="8.0"
ENV GRADLE_VERSION="8.13"
ENV JAVA_VERSION="17"

# upgrade all packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get upgrade -y

    # NodeJS
RUN wget --https-only --max-redirect=0 -qO- "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" | tar -xJ -C /usr/local --strip-components=1 \
    # Go
    && wget --https-only --max-redirect=0 -qO- "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local \
    # .NET
    && wget --https-only --max-redirect=0 -q https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel "${DOTNET_VERSION}" --install-dir /usr/share/dotnet \
    && rm /tmp/dotnet-install.sh \
    # Java
    && wget --https-only --max-redirect=2 -q "https://api.adoptium.net/v3/binary/latest/${JAVA_VERSION}/ga/linux/x64/jdk/hotspot/normal/adoptium" \
        -O /tmp/jdk.tar.gz \
    && mkdir -p "/usr/lib/jvm/temurin-${JAVA_VERSION}" \
    && tar -xz -C "/usr/lib/jvm/temurin-${JAVA_VERSION}" --strip-components=1 -f /tmp/jdk.tar.gz \
    && rm /tmp/jdk.tar.gz \
    # Gradle
    && wget --https-only --max-redirect=2 -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && mkdir /opt/gradle \
    && unzip -d /opt/gradle "gradle-${GRADLE_VERSION}-bin.zip" \
    && rm "gradle-${GRADLE_VERSION}-bin.zip"

ENV GOPATH="/usr/local/go"
ENV DOTNET_ROOT="/usr/share/dotnet"
ENV JAVA_HOME="/usr/lib/jvm/temurin-${JAVA_VERSION}"
ENV PATH="${PATH}:/usr/local/go/bin:/usr/share/dotnet:/usr/lib/jvm/temurin-${JAVA_VERSION}/bin:/opt/gradle/gradle-${GRADLE_VERSION}/bin"
