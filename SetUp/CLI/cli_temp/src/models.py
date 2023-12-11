# -*- coding: utf-8 -*-
"""
Created on Fri 29 15:46:32 2022

components for neural network

@author: tadahaya
"""
import torch
import torch.nn as nn
import torch.nn.functional as F

import numpy as np

class Block(nn.Module):
    """ network block """
    def __init__(self):
        super().__init__()
        # prepare own block

    def forward(self, x):
        """ forward function """
        raise NotImplementedError


class MyNet(nn.Module):
    """ network """
    def __init__(self, output_dim):
        super().__init__()
        # prepare own network

    def forward(self, x):
        """ forward function """
        raise NotImplementedError

    def predict(self, x):
        """ function for inference """
        raise NotImplementedError
