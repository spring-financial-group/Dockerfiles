FROM jx3mqubebuild.azurecr.io/docker-io/library/ubuntu:22.04

WORKDIR /source
COPY . .

RUN apt update \
    && apt install -y wget curl openssl ca-certificates \
    && mkdir /java    \
    && wget https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_linux-x64_bin.tar.gz \
    && tar -xzvf openjdk-14.0.2_linux-x64_bin.tar.gz -C /java \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /source/*

ENV JAVA_HOME="/java/jdk-14.0.2/bin"
ENV PATH=$JAVA_HOME:$PATH
CMD ["bash"]
