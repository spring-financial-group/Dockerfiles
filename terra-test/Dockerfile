FROM jx3mqubebuild.azurecr.io/docker-io/library/golang:1.24

RUN apt-get update \
    && apt-get install -y unzip jq \
    && TERRAFORM_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json \
        | jq -r '.versions | to_entries[] | select(.key | test("^(?!.*(alpha|beta|rc)).*")) | .key' \
        | sort -V \
        | tail -1) \
    && echo "Latest Terraform version: $TERRAFORM_VERSION" \
    && TERRAFORM_URL=$(curl -sL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/index.json" \
        | jq -r '.builds[] | select(.arch == "amd64" and .os == "linux") | .url') \
    && wget "$TERRAFORM_URL" \
    && export TERRAFORM_FILENAME=$(echo "$TERRAFORM_URL" | grep -oP '[^/]+\.zip$') \
    && unzip "$TERRAFORM_FILENAME" && echo "$TERRAFORM_FILENAME" \
    && rm "$TERRAFORM_FILENAME" \
    && mv terraform /usr/local/go/bin/terraform \
    && curl -L -o tfsec "https://github.com/aquasecurity/tfsec/releases/download/v1.28.14/tfsec-linux-amd64" \
    && chmod +x tfsec \
    && mv tfsec /usr/local/bin

CMD ["bash"]
