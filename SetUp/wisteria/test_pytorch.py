# -*- coding: utf-8 -*-
"""
Author: Katsuhisa Morita

test module of pytorch for wisteria
"""
# import
import numpy as np
import pandas as pd

import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision import datasets, transforms

# set parameters
num_epochs = 10
num_batch = 100
learning_rate = 0.001
image_size = 28*28
folder="/work/ga97/a90071/mnist"

# Neural Net
class Net(nn.Module):
    def __init__(self, input_size, output_size):
        super(Net, self).__init__()
        self.fc1 = nn.Linear(input_size, 100)
        self.fc2 = nn.Linear(100, output_size)

    def forward(self, x):
        x = self.fc1(x)
        x = torch.sigmoid(x)
        x = self.fc2(x)
        return F.log_softmax(x, dim=1)

device = 'cuda' if torch.cuda.is_available() else 'cpu'
print(f"device: {device}")

transform = transforms.Compose([
    transforms.ToTensor()
    ])

train_dataset = datasets.MNIST(
    folder,
    train = True,
    download = True,
    transform = transform
    )

test_dataset = datasets.MNIST(
    folder, 
    train = False,
    transform = transform
    )

train_dataloader = torch.utils.data.DataLoader(
    train_dataset,
    batch_size = num_batch,
    shuffle = True)

test_dataloader = torch.utils.data.DataLoader(
    test_dataset,     
    batch_size = num_batch,
    shuffle = True)


model = Net(image_size, 10).to(device)
criterion = nn.CrossEntropyLoss() 
optimizer = torch.optim.Adam(model.parameters(), lr = learning_rate) 

model.train()
for epoch in range(num_epochs): # 学習を繰り返し行う
    loss_sum = 0
    for inputs, labels in train_dataloader:
        inputs = inputs.to(device)
        labels = labels.to(device)
        optimizer.zero_grad()
        inputs = inputs.view(-1, image_size)
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss_sum += loss
        loss.backward()
        optimizer.step()
    print(f"Epoch: {epoch+1}/{num_epochs}, Loss: {loss_sum.item() / len(train_dataloader)}")

model.eval()
loss_sum = 0
correct = 0
with torch.no_grad():
    for inputs, labels in test_dataloader:
        inputs = inputs.to(device)
        labels = labels.to(device)
        inputs = inputs.view(-1, image_size)
        outputs = model(inputs)
        loss_sum += criterion(outputs, labels)
        pred = outputs.argmax(1)
        correct += pred.eq(labels.view_as(pred)).sum().item()

print(f"Loss: {loss_sum.item() / len(test_dataloader)}, Accuracy: {100*correct/len(test_dataset)}% ({correct}/{len(test_dataset)})")
print("pytorch*MNIST test completed")