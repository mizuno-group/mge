# Ubuntu20.04

https://qiita.com/tkyonezu/items/0f6da57eb2d823d2611d

上記を参考にした。

## apt-getの更新

```
$ sudo apt-get update
```

## 必要ソフトウェアのインストール

```
$ sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```
## GPG公開鍵のインストール

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

GPG公開鍵はソフトウェアのインストールもとなどが正しいと検証する際に必要。

## aptリポジトリの設定

```
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```
## docker-ceのインストール

```
$ sudo apt-get update
$ sudo apt-get install -y docker-ce
```

これで完了。

## sudoなしで実行できるようにする

推奨。

```
$ sudo usermod -aG docker <アカウント名>
```
