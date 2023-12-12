# ■ 内容
Anaconda仮想環境でRを動かす.  
Rはversion違いの依存関係が結構大きいイメージなので適宜スイッチできることを目的にする.  

***
# ■ 条件
## - OS -
CentOS7想定だがおそらく他でも可能. 

## - 日付 -
2020/5/22  

***
# ■ 仮想環境構築
anacondaは既に入っている想定.  
一般ユーザーにて.  
- [参考1](http://salvatoregiorgi.com/blog/2018/10/16/installing-an-older-version-of-r-in-a-conda-environment/)  
- [参考2](https://docs.anaconda.com/anaconda/user-guide/tasks/using-r-language/)  
- [参考3](https://dermasugita-notebook.a1tos.com/2019/04/28/568/)  

## 1. condaで仮想環境を作る
`conda create -n [テキトーな環境名]`  
* 参考だと環境名の後ろにanacondaと引数で与えていたが役割はわからずにいる.  

## 2. Rのバージョン探索
バージョンをsearchする.  
バージョンと同時にchannelも表示される.  

    
    conda activate [テキトーな環境名] # activateする
    conda search r-base # Rのバージョンを探す
    
    
## 3. Rのインストール
見つけたバージョン, チャンネルを指定してconda install  
    
    
    conda install -c conda-forge r=3.5.3 # conda-forgeの部分がchannel
    which R # Rの場所確認, 環境内にいることをチェック
    R --version # Rのバージョン確認
    
* installするパッケージに=でつなげてバージョンを書くと当該バージョンがインストールされる.  

***
# ■ 使用方法
## 1. 作ったR環境に入る
`conda activate [環境名]`  

## 2. Rの起動/終了
* 起動 `R`  
* 終了 `q()`  
* 起動してからはいつものコンソールでのRと同じ.  
* getwd(), setwd()で場所を忘れない.  
* 2020/5/22現在, `R`で起動しようとすると怒られる. pyenv globalのpathの問題らしい

## (パッケージ周り)
* インストール  
`install.packages("XXXX")`

* 読み込み  
`library("XXXX")`
