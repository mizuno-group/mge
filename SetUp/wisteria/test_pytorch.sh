#!/bin/sh
#PJM -L rscgrp=debug-a
#PJM -L node=1
#PJM -L elapse=0:10:00
#PJM -g ga97

# moduleのload
module load cuda/11.3
module load cudnn/8.2.0

# 仮想環境の構築 (mvenv)
python3 -mvenv tempenv --clear
source tempenv/bin/activate

# package install
pip3 install --upgrade pip setuptools
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
pip3 install numpy pandas

# 実行
python3 test_pytorch.py