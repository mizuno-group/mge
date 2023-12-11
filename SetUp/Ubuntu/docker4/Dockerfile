FROM dorowu/ubuntu-desktop-lxde-vnc

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.1.1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-1=11.1.74-1 \
    cuda-compat-11-1 \
    && ln -s cuda-11.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.1 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

ENV NCCL_VERSION 2.7.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-nvml-dev-11-1=11.1.74-1 \
    cuda-command-line-tools-11-1=11.1.1-1 \
    cuda-nvprof-11-1=11.1.105-1 \
    libnpp-dev-11-1=11.1.2.301-1 \
    cuda-libraries-dev-11-1=11.1.1-1 \
    cuda-minimal-build-11-1=11.1.1-1 \
    libnccl-dev=2.7.8-1+cuda11.1 \
    libcublas-dev-11-1=11.3.0.106-1 \
    libcusparse-11-1=11.3.0.10-1 \
    libcusparse-dev-11-1=11.3.0.10-1 \
    && apt-mark hold libnccl-dev \
    && rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-1=11.1.1-1 \
    libnpp-11-1=11.1.2.301-1 \
    cuda-nvtx-11-1=11.1.74-1 \
    libcublas-11-1=11.3.0.106-1 \
    libnccl2=$NCCL_VERSION-1+cuda11.1 \
    && apt-mark hold libnccl2 \
    && rm -rf /var/lib/apt/lists/*

#CMD ["rm", "/startup.sh"]
ADD ./startup.sh /
RUN chmod +x /startup.sh
# ユーザーを作成
ARG DOCKER_UID=1000
ARG DOCKER_USER=docker
ARG DOCKER_PASSWORD=docker
　RUN useradd -m --uid ${DOCKER_UID} --groups sudo ${DOCKER_USER} \
  && echo ${DOCKER_USER}:${DOCKER_PASSWORD} | chpasswd

ENV HOME /home/${DOCKER_USER}
ENV USER ${DOCKER_USER}
ENV PASSWORD ${DOCKER_PASSWORD}

ADD sudoers /etc
 #作成したユーザーに切り替える
USER ${DOCKER_USER}

RUN sudo apt-get update \
    && sudo apt-get install -y language-pack-ja-base language-pack-ja fonts-noto-cjk fcitx-mozc \
    && sudo im-config -n fcitx

ENV GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx \
    DefalutIMModule=fcitx

RUN sudo locale-gen ja_JP.UTF-8  
ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

RUN sudo apt-get update --fix-missing && \
    sudo apt-get install -y wget

WORKDIR /home/${DOCKER_USER}

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh && \
    /bin/bash ./Miniconda3-4.5.11-Linux-x86_64.sh -b && \
    rm ./Miniconda3-4.5.11-Linux-x86_64.sh && \
    export PATH=~/miniconda3/bin:$PATH && \
    echo ". /home/docker/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    sudo ln -s /home/${DOCKER_USER}/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo "conda activate" >> ~/.bashrc && \
    . /home/${DOCKER_USER}/miniconda3/etc/profile.d/conda.sh && \
    conda activate && \
    conda create -y -n pytorch-gpu && \
    conda activate pytorch-gpu && \
    conda install -y pytorch torchvision torchaudio cudatoolkit=11.0 -c pytorch

RUN sudo apt update && \
    sudo apt install git

USER root