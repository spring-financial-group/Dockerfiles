FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:1.24

RUN apt-get update \
    && apt-get install -y unzip jq \
    && export LATEST_TF_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep -v 'rc|beta|alpha' | egrep 'linux.*amd64'  | tail -1) \
    && wget $LATEST_TF_VERSION \
    && export TERRAFORM_FILENAME=$(echo $LATEST_TF_VERSION | grep -oP '[^/]+\.zip$') \
    && unzip $TERRAFORM_FILENAME && echo $TERRAFORM_FILENAME \
    && rm $TERRAFORM_FILENAME \
    && mv terraform /usr/local/go/bin/terraform \
    && curl -L -o tfsec "https://github.com/aquasecurity/tfsec/releases/download/v1.28.14/tfsec-linux-arm64" \
    && chmod +x tfsec \
    && mv tfsec /usr/local/bin

CMD ["bash"]
