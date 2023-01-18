# TODO: Make cuda version selectable
ARG CUDA_VERSION=12.0.0
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu20.04
ARG GPU_ARCHITECTURE=sm_86

WORKDIR /usr/src/app

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && \
    apt install --no-install-recommends -y build-essential software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt install --no-install-recommends -y python3.9 python3-pip python3-setuptools python3-distutils && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y build-essential  && \
    apt-get install -y \
    gnupg \
    wget \
    git \
    libhdf5-dev \
    mesa-common-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV GPU_ARCHITECTURE=${GPU_ARCHITECTURE}

ADD "https://api.github.com/repos/szvsw/pffdtd/commits?per_page=1" latest_commit

# Consider making repo and branch configurable
RUN git clone https://github.com/szvsw/pffdtd 
WORKDIR /usr/src/app/pffdtd/c_cuda
RUN git checkout set-gpu-architecture && git pull 
RUN make all

WORKDIR /usr/src/app/pffdtd/python
RUN python3.9 -m pip install --upgrade pip && \
    python3.9 -m pip install --no-cache-dir -r pip_requirements.txt


CMD [ "tail", "-F", "anything"]