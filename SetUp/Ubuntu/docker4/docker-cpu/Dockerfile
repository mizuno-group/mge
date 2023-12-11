FROM dorowu/ubuntu-desktop-lxde-vnc

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

ENV PATH /home/${DOCKER_USER}/miniconda3/bin:$PATH

RUN sudo apt-get update --fix-missing && \
    sudo apt-get install -y wget

WORKDIR /home/${DOCKER_USER}

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh && \
    /bin/bash ./Miniconda3-4.5.11-Linux-x86_64.sh -b && \
    rm ./Miniconda3-4.5.11-Linux-x86_64.sh && \
    echo ". /home/docker/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    sudo ln -s /home/${DOCKER_USER}/miniconda3/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo "conda activate" >> ~/.bashrc

RUN sudo apt update && \
    sudo apt install -y git

USER root