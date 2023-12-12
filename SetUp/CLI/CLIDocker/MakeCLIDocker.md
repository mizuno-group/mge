# CLI Dockerの作り方

## 概要
コマンドライン上でCLIのDockerを作成すると, 通常はそのコマンドラインが終了したときにDockerも同時に終了してしまう。  
特に, 計算機にssh接続してDockerを作成している場合, ネットワークの切断などによりssh接続が切れるとDockerが終了してしまう。  
そこで, ここではコマンドラインが終了してもDockerが残るようにする方法を説明する。

## 方法
### 1. Docker Imageの作成
[水野先生によるcode sereverの作り方](https://github.com/mizuno-group00/environment/tree/miz/Docker/codeserver/coder_gpu) や [前寺さんによるGUI Dockerの作り方](https://github.com/mizuno-group00/environment/blob/master/Docker/DockerGUIContainerOnUbuntu.md) などを参考に作りたいDockerのイメージを作成する。以下は一例。
~~~
$ docker build -t <image名>:<version> <ビルドするDockerfileが存在するディレクトリ>
~~~

### 2. Dockerを建てる
Dockerを建てたい計算機のコマンドライン上で,   
~~~
$ docker create -it -v /dev/shm:/dev/shm --mount type=bind,source=<マウント元ディレクトリ>,target=<マウント先ディレクトリ> --name <Docker名> <イメージ名>:<バージョン> /bin/bash
~~~
と実行する。 GPUを使いたい場合はオプションに
~~~
 --gpus all
 ~~~
を指定する。コマンドの説明については[前寺さんによるGUI Dockerの作り方](https://github.com/mizuno-group00/environment/blob/master/Docker/DockerGUIContainerOnUbuntu.md)に詳しく書かれている。変更点としては, マウントの方式をvolume マウントからbind マウントに変更している。

### 3. Dockerを起動する
2 でDockerを建てた状態では, まだ起動していない。Dockerを起動するには, 計算機のコマンドラインで
~~~
$ docker start -ai <Docker名>
~~~
と実行する。これでDocker内の端末にアクセスできる。

### 4. 一度切断したDockerに再度アクセスする
一度建てたDockerの端末にアクセスには,計算機のコマンドラインで
~~~
$ docker attach <Docker名>
~~~
と実行する。






