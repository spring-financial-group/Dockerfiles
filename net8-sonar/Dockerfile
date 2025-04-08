FROM jx3mqubebuild.azurecr.io/spring-financial-group/net8-integration-tests:latest 

RUN apt install -y openjdk-17-jre rsync

RUN curl -L https://github.com/jenkins-x/jx/releases/download/v3.11.76/jx-linux-amd64.tar.gz | tar xzv
RUN chmod +x jx
RUN mv jx /usr/local/bin/jx

CMD ["bash"]
