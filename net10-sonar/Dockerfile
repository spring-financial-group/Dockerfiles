FROM mcr.microsoft.com/dotnet/sdk:10.0-bookworm-slim

# Unlike the net8 image, no libssl1.1 install is needed: Mongo2Go 5+ bundles
# MongoDB 8, which links libssl.so.3 (shipped with bookworm). Repos scanned on
# this image must use Mongo2Go 5.0.0 or later in their test projects.
RUN apt update && apt install -y openjdk-17-jre rsync

RUN curl -L https://github.com/jenkins-x/jx/releases/download/v3.11.76/jx-linux-amd64.tar.gz | tar xzv
RUN chmod +x jx
RUN mv jx /usr/local/bin/jx

CMD ["bash"]
