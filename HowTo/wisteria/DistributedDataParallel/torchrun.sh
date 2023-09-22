#!/bin/bash

torchrun \
  --nproc_per_node=8 \
  --nnodes=2 \
  --node_rank=$OMPI_COMM_WORLD_RANK \
  --rdzv_id=456 \
  --rdzv_backend=c10d \
  --rdzv_endpoint=$1:12355 \
  MNIST_DDP.py --total_epochs 10 --save_every 1