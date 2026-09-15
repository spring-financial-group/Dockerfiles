FROM jx3mqubebuild.azurecr.io/docker-io/nvidia/cuda:11.7.1-base-ubuntu22.04

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gcc \
        gfortran \
        git \
        libexpat1-dev \
        libgl1-mesa-dev \
        libglib2.0-0 \
        liblapack-dev \
        libopenblas-dev \
        libpython3-dev \
        libsm6 \
        libxext6 \
        libxrender1 \
        make \
        poppler-utils \
        python3 \
        python3-dev \
        python3-distutils \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

RUN ln -s /usr/bin/pydoc3 /usr/local/bin/pydoc \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && ln -s /usr/bin/python3-config /usr/local/bin/python-config \
    && python get-pip.py
RUN pip install --upgrade pip \
    && pip install --upgrade setuptools \
    && pip install uv
CMD ["bash"]
