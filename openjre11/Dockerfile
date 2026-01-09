FROM jx3mqubebuild.azurecr.io/docker-io/library/ubuntu:22.04
RUN apt update \
    && apt install -y openjdk-11-jre \
    && rm -rf /var/lib/apt/lists/*
CMD ["bash"]
