# === description ===
# base dockerfile for code-server in docker

# === composition ===
# 1. desired environment
# 2. code-server setting

# === history ===
# 220421 start writing

# 1. desired environment
FROM python:3.9-slim-buster

# linux setting
RUN mkdir /workspace
WORKDIR /workspace
ENV TZ=Asia/Tokyo

RUN apt-get update \
  && apt-get install -y \
  curl \
  vim \
  less \
  git \
  tzdata \
  nodejs \
  npm \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y locales \
  && locale-gen ja_JP.UTF-8 \
  && echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

# python setting
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install --no-cache-dir \
  jupyter \
  flake8 \
  autopep8

# python specific packages indicated by requirements.txt
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

# 2. code-server setting
# RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server \
  --install-extension ms-python.python \
  --install-extension ms-ceintl.vscode-language-pack-ja