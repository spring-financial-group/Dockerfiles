# BlackArch-inspired Security Scanning Image
# Contains common security tools for CI/CD pipeline scanning
FROM jx3mqubebuild.azurecr.io/docker-io/library/alpine:3.21

# Install base packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        curl \
        wget \
        jq \
        git \
        python3 \
        python3-dev \
        py3-pip \
        nodejs \
        npm \
        nmap \
        nmap-scripts \
        openssl \
        ca-certificates \
        unzip \
        build-base \
        go \
        perl

# Install kubectl from official release
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install kubectl from official release
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Trivy (container/filesystem vulnerability scanner)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Gitleaks (secret detection) - using fixed version to avoid GitHub API rate limits
ENV GITLEAKS_VERSION=8.30.0
RUN wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -O /tmp/gitleaks.tar.gz && \
    tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks && \
    rm /tmp/gitleaks.tar.gz

# Install Semgrep (static analysis)
RUN pip3 install --no-cache-dir semgrep --break-system-packages

# Install Nuclei (vulnerability scanner) - using prebuilt binary
ENV NUCLEI_VERSION=3.3.7
RUN wget -q "https://github.com/projectdiscovery/nuclei/releases/download/v${NUCLEI_VERSION}/nuclei_${NUCLEI_VERSION}_linux_amd64.zip" -O /tmp/nuclei.zip && \
    unzip -q /tmp/nuclei.zip -d /usr/local/bin && \
    rm /tmp/nuclei.zip

# Install npm security tools
RUN npm install -g \
    npm-audit-html \
    retire \
    snyk

# Install nikto (web server scanner) - from source since not in Alpine
RUN git clone https://github.com/sullo/nikto.git /opt/nikto

# Create symlinks for easy access
RUN ln -s /opt/nikto/program/nikto.pl /usr/local/bin/nikto

# Update Nuclei templates
RUN nuclei -update-templates || true

# Clean up
RUN rm -rf /var/cache/apk/* /root/go /tmp/*

# Set working directory
WORKDIR /workspace

CMD ["bash"]