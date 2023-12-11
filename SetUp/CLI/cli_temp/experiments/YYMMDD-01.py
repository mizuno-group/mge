# -*- coding: utf-8 -*-
"""
CLI_template
CLIで深層学習を動かすときのpseudoコード
cli_testにて実際にgoogle colabで動くように記載したものを公開

以下の形をベースとする:
  prepare_data: (train_loader, test_loader) or test_loader返す
  prepare_model: model, loss, optimizer, scheduler返す
  fit: 学習する
    train_epoch: epoch単位でのtraining
  predict: 推論する

@author: tadahaya
"""
# path setting
## この.pyが所属するPROJECTのパス, 必須入力
## PROJECT/notebooksにこの.pyは格納している, PROJECTのパスを指定する
PROJECT_PATH = '/content/drive/MyDrive/cli_temp'

# packages installed in the current environment
import sys

from symbol import parameters
sys.path.append(PROJECT_PATH)
import os
import datetime
import argparse
import numpy as np
import torch
from tqdm import trange

# original packages in src
from src import utils
from src.models import MyNet


# setup
now = datetime.datetime.now().strftime('%H%M%S')
file = os.path.basename(__file__).split('.')[0]
DIR_NAME = PROJECT_PATH + '/results/' + file + '_' + now # for output
if not os.path.exists(DIR_NAME):
    os.makedirs(DIR_NAME)
LOGGER = utils.init_logger(file, DIR_NAME, now, level_console='debug') # for logger
DEVICE = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu') # get device


# === 基本的にタスクごとに変更 ===
# argumentの設定, 概ね同じセッティングの中で振りうる条件を設定
parser = argparse.ArgumentParser(description='CLI template')
parser.add_argument('--note', type=str, help='short note for this running')
args = parser.parse_args()
utils.fix_seed(seed=args.seed, fix_gpu=False) # for seed control


def prepare_data():
    """
    データの読み込み・ローダーの準備を実施, train_loaderとtest_loader, あるいはtest_loaderのみを返す
    加工済みのものをdataにおいておくか, argumentで指定したパスから呼び出すなりしてデータを読み込む
    inference用を読み込む際のものも用意しておくと楽
    
    """
    if args.train:
        train_loader, test_loader = None, None
        return train_loader, test_loader
    else:
        test_loader = None
        return test_loader        


# model等の準備
def prepare_model():
    """
    model, loss, optimizer, schedulerの準備
    argumentでコントロールする場合には適宜if文使うなり

    """
    model = None
    criterion = None
    optimizer = None
    scheduler = None
    return model, criterion, optimizer, scheduler


# === 基本的に触らずでOK ===
def train_epoch(model, train_loader, test_loader, criterion, optimizer):
    """
    epoch単位の学習構成, なくとも良い
    パラメータを更新したモデルとtrain-/valid-lossのバッチ平均を返す
    
    """
    model.train() # training
    train_batch_loss = []
    for data, label in train_loader:
        # train loop
        pass
    model.eval() # test (validation)
    test_batch_loss = []
    with torch.no_grad():
        for data, label in test_loader:
            # valid loop
            pass
    return model, np.mean(train_batch_loss), np.mean(test_batch_loss)


def train(model, train_loader, test_loader, criterion, optimizer, scheduler):
    """
    学習
    model, train_loss, test_loss (valid_loss)を返す
    schedulerは使わないことがあるか, その場合は適宜除外
    
    """
    train_loss = []
    test_loss = []
    for epoch in trange(args.num_epoch):
        # training loop
        pass
    return model, train_loss, test_loss


def predict(model, dataloader):
    """
    推論
    学習済みモデルとdataloaderを入力に推論
    予測値と対応するラベル, 及びaccuracyを返す
    
    """
    model.eval()
    preds, labels = [], []
    correct, total = 0.0, 0
    with torch.no_grad():
        for data, label in dataloader:
            # evaluation loop
            pass
    return preds, labels, correct/total


if __name__ == '__main__':
    # argumentでtrainとevalを分けてevalのみでもできるようにしておくと楽
    if args.train:
        # training mode
        # 1. data prep
        train_loader, test_loader = prepare_data()
        # 2. model prep
        model, loss, optimizer, scheduler = prepare_model()
        # 3. training
        model, train_loss, test_loss = train()
        # 4. evaluation
        preds, labels, acc = predict()
        # 5. save results & config
        ## loggerを活用
    else:
        # inference mode
        pass