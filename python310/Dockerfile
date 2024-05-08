FROM ubuntu:22.04
RUN apt-get update \
    && apt-get install gcc -y
RUN apt upgrade -y
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -yq git libopencv-dev python3-opencv libglib2.0-0 libsm6 libxrender1 libxext6 libexpat1-dev libpython3-dev libpython3.10-dev python3-dev python3 python3-distutils wget curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN ln -s /usr/bin/pydoc3 /usr/local/bin/pydoc \
    && ln -s /usr/bin/python3 /usr/local/bin/python \
    && ln -s /usr/bin/python3-config /usr/local/bin/python-config \
    && python get-pip.py
RUN pip install --upgrade pip \
    && pip install --upgrade setuptools \
    && pip install pipenv
CMD ["bash"]
