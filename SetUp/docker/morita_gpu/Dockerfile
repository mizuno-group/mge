FROM dorowu/ubuntu-desktop-lxde-vnc

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.0.3

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-0=11.0.221-1 \
    cuda-compat-11-0 \
    && ln -s cuda-11.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.0 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 brand=tesla,driver>=450,driver<451"

ENV NCCL_VERSION 2.7.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-0=11.0.3-1 \
    libnpp-11-0=11.1.0.245-1 \
    cuda-nvtx-11-0=11.0.167-1 \
    libcublas-11-0=11.2.0.252-1 \
    && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install curl xz-utils -y --no-install-recommends && NCCL_DOWNLOAD_SUM=34000cbe6a0118bfd4ad898ebc5f59bf5d532bbf2453793891fa3f1621e25653 && \
    curl -fsSL https://developer.download.nvidia.com/compute/redist/nccl/v2.7/nccl_2.7.8-1+cuda11.0_x86_64.txz -O && \
    echo "$NCCL_DOWNLOAD_SUM  nccl_2.7.8-1+cuda11.0_x86_64.txz" | sha256sum -c - && \
    tar --no-same-owner --keep-old-files --lzma -xvf nccl_2.7.8-1+cuda11.0_x86_64.txz -C /usr/local/cuda/lib64/ --strip-components=2 --wildcards '*/lib/libnccl.so.*' && \
    tar --no-same-owner --keep-old-files --lzma -xvf  nccl_2.7.8-1+cuda11.0_x86_64.txz -C /usr/lib/pkgconfig/ --strip-components=3 --wildcards '*/lib/pkgconfig/*' && \
    rm nccl_2.7.8-1+cuda11.0_x86_64.txz && \
    ldconfig && rm -rf /var/lib/apt/lists/*

ENV NCCL_VERSION 2.7.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-nvml-dev-11-0=11.0.167-1 \
    cuda-command-line-tools-11-0=11.0.3-1 \
    cuda-nvprof-11-0=11.0.221-1 \
    libnpp-dev-11-0=11.1.0.245-1 \
    cuda-libraries-dev-11-0=11.0.3-1 \
    cuda-minimal-build-11-0=11.0.3-1 \
    libcublas-dev-11-0=11.2.0.252-1 \
    libcusparse-11-0=11.1.1.245-1 \
    libcusparse-dev-11-0=11.1.1.245-1 \
    && rm -rf /var/lib/apt/lists/*

RUN apt update && apt install curl xz-utils -y --no-install-recommends && NCCL_DOWNLOAD_SUM=34000cbe6a0118bfd4ad898ebc5f59bf5d532bbf2453793891fa3f1621e25653 && \
    curl -fsSL https://developer.download.nvidia.com/compute/redist/nccl/v2.7/nccl_2.7.8-1+cuda11.0_x86_64.txz -O && \
    echo "$NCCL_DOWNLOAD_SUM  nccl_2.7.8-1+cuda11.0_x86_64.txz" | sha256sum -c - && \
    tar --no-same-owner --keep-old-files --lzma -xvf  nccl_2.7.8-1+cuda11.0_x86_64.txz -C /usr/local/cuda/include/ --strip-components=2 --wildcards '*/include/*' && \
    tar --no-same-owner --keep-old-files --lzma -xvf  nccl_2.7.8-1+cuda11.0_x86_64.txz -C /usr/local/cuda/lib64/ --strip-components=2 --wildcards '*/lib/libnccl.so' && \
    rm nccl_2.7.8-1+cuda11.0_x86_64.txz && \
    ldconfig && rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs


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
    conda -c conda-forge xgboost lightgbm optuna -y && \
    conda install numpy pandas scikit-learn scipy tqdm pickle5 spyder statsmodels matplotlib seaborn -y && \
    pip install tensorflow keras

RUN sudo apt update && \
    sudo apt install -y git

USER root