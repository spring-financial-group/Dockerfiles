FROM jx3mqubebuild.azurecr.io/docker-io/library/ubuntu:24.04

# Use --no-install-recommends to keep the image lean
# Clean up apt caches in the SAME layer to save space
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gcc \
    libpmix2 \
    wget \
    make \
    git \
    libopencv-dev \
    python3-opencv \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libexpat1-dev \
    curl \
    ca-certificates \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3.14 \
    python3.14-dev \
    python3.14-venv \
    && rm -rf /var/lib/apt/lists/*

# Install yq 
RUN wget https://github.com/mikefarah/yq/releases/download/v4.52.4/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

# Set up Python 3.14 and pip
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3.14 get-pip.py \
    && ln -s /usr/bin/python3.14 /usr/local/bin/python \
    && ln -s /usr/bin/python3.14 /usr/local/bin/python3 \
    && rm get-pip.py

# Install Python tools
RUN pip install --no-cache-dir --upgrade pip setuptools pipenv uv

CMD ["bash"]