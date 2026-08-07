FROM jx3mqubebuild.azurecr.io/docker-io/library/debian:13-slim

# Arguments
ARG CHROME_FOR_TESTING_VERSION=151.0.7922.47
ARG TZ=Europe/London

# Download and install Chrome for Testing, making it available on PATH as `chrome`
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    tzdata \
    unzip \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL -o /tmp/chrome.zip \
    "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_FOR_TESTING_VERSION}/linux64/chrome-linux64.zip" \
 && unzip -q /tmp/chrome.zip -d /opt \
 && rm /tmp/chrome.zip \
 && ln -s /opt/chrome-linux64/chrome /usr/local/bin/chrome

ENV TZ=${TZ}