FROM jx3mqubebuild.azurecr.io/docker-io/nvidia/cuda:12.6.3-base-ubuntu20.04
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y git libglib2.0-0 libsm6 libxrender1 libxext6 libexpat1-dev wget curl ca-certificates software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y python3.10 python3.10-dev python3.10-distutils python3.10-venv \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN ln -sf /usr/bin/python3.10 /usr/local/bin/python3 \
    && ln -sf /usr/bin/python3.10 /usr/local/bin/python \
    && ln -sf /usr/bin/python3.10-config /usr/local/bin/python3-config \
    && ln -sf /usr/bin/python3.10-config /usr/local/bin/python-config \
    && ln -sf /usr/bin/pydoc3.10 /usr/local/bin/pydoc \
    && python3.10 get-pip.py
RUN apt-get update && apt-get -y install gcc make git gfortran libopenblas-dev liblapack-dev poppler-utils libgl1-mesa-dev
RUN python3.10 -m pip install uv torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0
CMD ["bash"]
