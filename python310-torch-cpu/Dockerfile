FROM jx3mqubebuild.azurecr.io/spring-financial-group/python310:latest
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gfortran \
        libgl1-mesa-dev \
        liblapack-dev \
        libopenblas-dev \
        poppler-utils \
    && rm -rf /var/lib/apt/lists/*
CMD ["bash"]
