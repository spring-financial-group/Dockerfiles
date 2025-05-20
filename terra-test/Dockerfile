FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:1.24

RUN apt-get update \
    && apt-get install -y unzip jq \
    && export LATEST_TF_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep -v 'rc|beta|alpha' | egrep 'linux.*amd64'  | tail -1) \
    && wget $LATEST_TF_VERSION \
    && export TERRAFORM_FILENAME=$(echo $LATEST_TF_VERSION | grep -oP '[^/]+\.zip$') \
    && unzip $TERRAFORM_FILENAME && echo $TERRAFORM_FILENAME \
    && rm $TERRAFORM_FILENAME \
    && mv terraform /usr/local/go/bin/terraform \
    && curl -o tfsec "https://objects.githubusercontent.com/github-production-release-asset-2e65be/173785481/3f288391-9907-4cae-becb-a36702e195a4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250520%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250520T084628Z&X-Amz-Expires=300&X-Amz-Signature=b283d6238cc10ab64cdbf54defa65cfb1ebd1ce2aee84809b4e37ce90459dc7a&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3Dtfsec-linux-arm64&response-content-type=application%2Foctet-stream" \
    && chmod +x tfsec \
    && mv tfsec /usr/local/bin

CMD ["bash"]
