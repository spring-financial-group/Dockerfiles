FROM nvidia/cuda:11.6.2-base-ubuntu20.04
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y git libglib2.0-0 libsm6 libxrender1 libxext6 libexpat1-dev libpython3-dev libpython3.8-dev python3-dev python3 python3-distutils wget curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN ln -s /usr/bin/pydoc3 /usr/local/bin/pydoc \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && ln -s /usr/bin/python3-config /usr/local/bin/python-config \
    && python get-pip.py
RUN apt-get update && apt-get -y install gcc make git gfortran libopenblas-dev liblapack-dev poppler-utils libgl1-mesa-dev
RUN python3 -m pip install torch==1.11.0 torchvision==0.12.0 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu116
CMD ["bash"]
