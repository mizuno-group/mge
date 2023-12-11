FROM ubuntu

RUN apt-get update \
    && apt-get install -y language-pack-ja-base language-pack-ja fonts-noto-cjk fcitx-mozc \
    && im-config -n fcitx

# 動作確認用のGUIアプリをインストール
RUN apt-get update \
    && apt-get install -y leafpad

ENV GTK_IM_MODULE=xim \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx \
    DefalutIMModule=fcitx

RUN locale-gen ja_JP.UTF-8  
ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8

# ユーザーを作成
ARG DOCKER_UID=1000
ARG DOCKER_USER=docker
ARG DOCKER_PASSWORD=docker
RUN useradd -m \
  --uid ${DOCKER_UID} --groups sudo ${DOCKER_USER} \
  && echo ${DOCKER_USER}:${DOCKER_PASSWORD} | chpasswd

USER ${DOCKER_USER}

WORKDIR /home/${DOCKER_USER}/app