FROM mcr.microsoft.com/dotnet/sdk:10.0-bookworm-slim

RUN apt update && apt install -y gnupg

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C

RUN gpg --export --armor 3B4FE6ACC0B21F32 | apt-key add -
RUN gpg --export --armor 871920D1991BC93C | apt-key add -

RUN echo "deb http://security.ubuntu.com/ubuntu focal-security main" | tee /etc/apt/sources.list.d/focal-security.list

RUN apt update
RUN apt install -y libssl1.1

RUN apt install -y openjdk-17-jre rsync

RUN curl -L https://github.com/jenkins-x/jx/releases/download/v3.11.76/jx-linux-amd64.tar.gz | tar xzv
RUN chmod +x jx
RUN mv jx /usr/local/bin/jx

CMD ["bash"]
