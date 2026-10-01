FROM mcr.microsoft.com/playwright/dotnet:v1.62.0-noble

# Upgrade openssl ahead of the upstream image (CVE-2026-84782)
RUN apt-get update \
    && apt-get install -y --only-upgrade openssl libssl3t64 \
    && rm -rf /var/lib/apt/lists/*

# Install .NET 8
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --install-dir /usr/share/dotnet --channel 8.0
