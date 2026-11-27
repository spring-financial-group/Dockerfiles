FROM jx3mqubebuild.azurecr.io/mcr-microsoft-com/playwright/dotnet:v1.63.0-resolute

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Install .NET 10
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --install-dir /usr/share/dotnet --channel 10.0
