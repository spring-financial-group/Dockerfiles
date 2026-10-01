FROM jx3mqubebuild.azurecr.io/mcr-microsoft-com/dotnet/sdk:10.0-noble

RUN apt update && apt install -y openjdk-17-jre

RUN curl -L https://github.com/jenkins-x/jx/releases/download/v3.11.76/jx-linux-amd64.tar.gz | tar xzv
RUN chmod +x jx
RUN mv jx /usr/local/bin/jx

CMD ["bash"]
