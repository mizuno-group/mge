# SSH接続を利用してWindows10からUbuntu PC内のdockerをGUIで操作する

SSHは通信プロトコルの一種で、暗号化や認証技術を用いてclientとserverのsecureな接続を行う。通信の暗号化などを自動で行ってくれることや、鍵認証を利用できることがポイント。

## SSH接続

1. 鍵の作成

https://qiita.com/digdagdag/items/9e5c061e7d86e0af9a57

上記を参考にした。

Windows側で行う。powershellを起動する。

```
mkdir c:\Users\XXXXX\.ssh
```

```
PS C:\Users\XXXXX> ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (//.ssh/id_rsa): c:/Users/XXXXX/.ssh/<適当な名前を入れる、例id_rsa>
Enter passphrase (empty for no passphrase):<ここで適当なpassphraseを設定>
Enter same passphrase again:
Your identification has been saved in c:/Users/XXXXX/.ssh/id_rsa.
Your public key has been saved in c:/Users/XXXXX/.ssh/id_rsa.pub.
The key fingerprint is:
48:--:--:--:0b:bf:0a:fd:ff:--:--:--:--:--:--:-- XXXXX@YOUR SERVER NAME
The key's randomart image is:
+--[ RSA 2048]----+
|        略       |
+-----------------+```
```

この例では、```id_rsa```と```id_rsa.pub```が```c:/Users/XXXXX/.ssh```内に生成される。

この```id_rsa.pub```のようなpub拡張子がついている方が公開鍵になる。これをUSBメモリなどを使ってUbuntuに移す。

2. サーバ―側の設定

SSH接続の仕方は[```SSH/SSH_config.md```](https://github.com/mizuno-group0/environment/blob/master/SSH/SSH_config.md)を参照。


ところで、デフォルトで入っているPowerShellやWSLだけでもWindowsでSSH接続をする上では十分だが、dockerをGUI操作をするためにX11 forwardingなどが簡便にできるMobaXtermというソフトウェアがあるとのちのち便利。

https://mobaxterm.mobatek.net/

上記からインストール。無料版でよい。

## Docker

### インストール

```UbuntuDockerInstallation.md```を参照。

### ビルド

dockerの仕組みについて概観。

dockerではまずDockerfileといういわば初期化手順記述ファイルを元にdocker imageを生成する。このdocker imageを作る過程をビルドと呼ぶ。ビルドされたdocker imageを元にdocker containerという仮想環境を作り、その中で種々の開発を行う。

docker imageに関しては既にビルド済みのものがいくつもDockerHubに公開されており、それを使う際には手元でビルドする必要はない。しかし、公開されているdocker imageに微調整を加えたい場合は、```Dockerfile```を書いて自分とビルドするのがよい。（後述の通り、```Dockerfile```を書く以外にも公開済みdocker imageを編集する方法はあるが、再現性の観点で見ると、```Dockerfile```を書くのがベター）

```
$ docker build -t <image名>:<version> <ビルドするDockerfileが存在するディレクトリ>
```

例えば、CPU環境で動く```ubuntu-desktop-mozc```のimageをビルドしたいときには

```
$ docker build -t ubuntu-desktop-mozc:ver1 ./ubuntu-desktop-mozc
```

などと指定。

```Dockerfile```の書き方は```EditingDockerfile.md```を参照

### containerの起動

docker imageが作成できたら、そのimageからcontainerを起動する。

```ubuntu-desktop-mozc```の場合は

```
$ docker run -p 6080:80 -e RESOLUTION=1920x1080 -v /dev/shm:/dev/shm -v <作業ディレクトリ>:<マウント先> --name ubuntu-desktop-mozc-container ubuntu-desktop-mozc:ver1
```

一つずつ解説していく。

#### ```-p 6080:80```

これはdocker container内のport 80をhostのport 6080にforwardingしている。これによって、host computerのport 6080にブラウザでアクセスすることで、docker conainerをGUIを操作できるようになる。（すべてのdocker imageにこのような機能があるわけではなく、特別にこれでGUIを操作できるようなimageを作った。）

#### ```-e RESOLUTION=1920x1080```

この```-e```はdocker container内の環境変数の変更に使う。今回の場合、```RESOLUTION```を```1920x1080```に変更している。こうすることでGUIにアクセスしたときにまともな画質になる。（必須ではない）

#### -v /dev/shm:/dev/shm

```-v```はhost computer中のあるディレクトリをdocker containerの中からアクセスできるようにするときに使う。すなわち、この場合はhost computer内の/dev/shmをdocker container内の/dev/shmに配置している。

/dev/shmは RAMディスクのマウントポイントとして使用されているらしい。詳しくはわかっていないが、このdocker imageを作る際に参考にした
https://hub.docker.com/r/dorowu/ubuntu-desktop-lxde-vnc/
において用いられていた。これによりhost computerのなんらかのファイルにdocker containerにアクセスできるようにしてGUIシステムの稼働などに役立てているのかもしれない。

#### -v <作業ディレクトリ>:<マウント先>

docker container内で作業してそのディレクトリの中でファイルなどを保存した際、取り出すのが非常に面倒になる。そこで、host computerや外付けHDDにdocker container内からアクセスできるようにし、そこを作業ディレクトリとすると、データの扱いが楽。たとえば、```/mnt/HDD:/HDD```とすれば、host computerの```/mnt/HDD```にdocker container内の```/HDD```からアクセス可能。

#### --name ubuntu-desktop-mozc-container

containerの名前

成功したら、host computerでブラウザを立ち上げて、```localhost:6080```に接続することで、GUIで操作できるようになる。

### 日本語入力

画面左下の紙飛行機？のようなアイコンをクリックして、設定をクリック。そして、Fcitxの設定をクリック。すると、画面右下にキーボードのようなアイコンが出てくる。ctrl+spaceキーを押すとこのアイコンがオレンジ色の「あ」が書いてある丸（mozc）に切り替わり、日本語入力ができるようになる。以降、通常時と同様、半角/全角キーで直接入力/ローマ字かな入力の切り替えができるようになる。

### containerのstop

containerを起動したターミナルでctrl+Cを押す。この時点でdocker container内の情報が揮発することはない。

### containerの再起動

```
$ docker start <container名>
```

### 起動中のcontainer一覧の取得

```
$ docker ps
```

### 停止中のcontainer一覧の取得

```
$ docker ps -a
```

### containerの保存

containerに加えた変更をimageに反映させたいときがある。```Dockerfile```の編集が一つの方法だがより簡単に、

```
$ docker commit <container名> <保存先image名>
```

とすることでcontainerの情報を保持したimageを作成することができる。しかし、どのような操作が加えられて作られたimageなのかわからず、再現性の観点からそこまでおすすめできない。

## リモート接続でdocker containerにアクセス

SSH接続と組み合わせ、リモート接続でできるようにする。といってもやり方はSSH接続でポートフォワーディングを行い、host computerの```6080```にclient computerの適当なポート（ここでは```8080```としよう）からアクセスできるようにするだけである。

### MobaXtermの場合

1. 画面上部のTunnelingを押す。
2. New SSH Tunnelingをクリック。
3. Local port forwardで、Forwarded portに```8080```を入力。
4. SSH serverはhost computerのIPアドレスを、SSH loginにはhost computerでログインに使うアカウント名を、SSH portにはSSH接続で用いるポートをそれぞれ入れる。
5. Remote serverには```localhost```をRemote portには```6080```をいれる。
6. saveをクリック。
7. 開始。

これでforwardingがうまくいっている＋docker containerが正常に起動しているのであれば、client computerのブラウザで```localhost:8080```にアクセスすると、docker container内で展開されているGUIにアクセス可能。

## GPUに対応させる  

GPUを動かすためには、nvidia-container-toolkitが必要で、nvidia-docker2をインストールすればよい。  
参考：https://medium.com/nvidiajapan/nvidia-docker-%E3%81%A3%E3%81%A6%E4%BB%8A%E3%81%A9%E3%81%86%E3%81%AA%E3%81%A3%E3%81%A6%E3%82%8B%E3%81%AE-20-09-%E7%89%88-558fae883f44  

```bash
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
$ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
$ sudo apt-get update
$ sudo apt-get install -y nvidia-docker2
$ sudo systemctl restart docker
```  

起動時に`--gpus <gpu数>`のオプションを付記すればよい。