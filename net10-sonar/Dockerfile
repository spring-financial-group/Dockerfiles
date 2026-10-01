FROM mcr.microsoft.com/dotnet/sdk:10.0-bookworm-slim

# libssl1.1 (not in bookworm) is required by the MongoDB 4.4 mongod binary bundled with Mongo2Go
RUN curl -sSL http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.24_amd64.deb -o /tmp/libssl1.1.deb \
    && dpkg -i /tmp/libssl1.1.deb \
    && rm /tmp/libssl1.1.deb

RUN apt update && apt install -y openjdk-17-jre rsync

RUN curl -L https://github.com/jenkins-x/jx/releases/download/v3.11.76/jx-linux-amd64.tar.gz | tar xzv
RUN chmod +x jx
RUN mv jx /usr/local/bin/jx

CMD ["bash"]
