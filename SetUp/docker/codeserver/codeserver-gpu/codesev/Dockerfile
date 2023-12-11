# === description ===
# base dockerfile for code-server in docker

# === composition ===
# 1. desired environment
# 2. code-server setting

# === history ===
# 220421 start writing

# 1. desired environment
FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04  
# Corresponding PyTorch version

# linux setting
RUN mkdir /workspace
WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y tzdata

ENV TZ=Asia/Tokyo

RUN apt-get update \
    && apt-get install -y \
    curl \
    vim \
    less \
    git \
    nodejs \
    npm \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y locales \
  && locale-gen ja_JP.UTF-8 \
  && echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

# python setting
# install python package
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh && \
    /bin/bash ./Miniconda3-py39_4.12.0-Linux-x86_64.sh -b && \
    rm ./Miniconda3-py39_4.12.0-Linux-x86_64.sh && \
    export PATH=~/miniconda3/bin:$PATH && \
    echo ". ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    ln -s ~/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo "conda activate" >> /.bashrc && \
    . ~/miniconda3/etc/profile.d/conda.sh && \
    conda activate && \
    conda update conda && \
    conda create -y -n pip-env python=3.9 && \
    conda activate pip-env && \
    conda install -y -c conda-forge rdkit && \
    conda install -y pip && \
    pip install jupyter && \
    pip install torch==1.8.0+cu111 torchvision==0.9.0+cu111 torchaudio==0.8.0 -f https://download.pytorch.org/whl/cu111/torch_stable.html && \
    pip install torch-scatter torch-sparse torch-cluster torch-spline-conv -f https://pytorch-geometric.com/whl/torch-1.8.0+cu111.html && \
    pip install torch-geometric && \
    pip install e3fp optuna plotly scikit-learn tqdm gensim pubchempy xgboost lightgbm && \
    pip install git+https://github.com/samoturk/mol2vec && \
    git clone https://github.com/openbabel/openbabel.git && \
    apt-get install -y libxml2-dev libboost-all-dev libomp-dev zlib1g-dev libeigen3-dev libcairo2-dev cmake swig && \
    cd openbabel && \
    mkdir build && cd build && \
    cmake -DENABLE_OPENMP=ON -DBUILD_GUI=OFF -DPYTHON_EXECUTABLE=/workspace/miniconca3/envs/pip-env/bin/python3 -DPYTHON_BINDINGS=ON -DRUN_SWIG=ON .. && \
    make -j 33 && \
    make install && \
    pip install plip && \
    rm -rf /var/lib/apt/lists/*   

ENV LD_LIBRARY_PATH /workspace/openbabel/build/lib:${LD_LIBRARY_PATH} \
    PATH /workspace/openbabel/build/bin:${PATH}
   
# if you want to add files to the container
# COPY XXX /XXX
# RUN chmod 777 /XXX

# 2. code-server setting
RUN apt-get update && \
    curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server \
  --install-extension ms-python.python \
  --install-extension ms-ceintl.vscode-language-pack-ja
