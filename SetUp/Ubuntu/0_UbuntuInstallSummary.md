# Ubuntu 20.04をクリーンインストールする
# 220109 tadahaya
Ubuntu20.04をクリーンインストールする際の流れをざっくりまとめる.  
以下のフローで行う.  

1. インストールディスクの準備  
2. インストール  
3. ネットワークの設定  
4. セキュリティの設定  
5. ディスクのマウント  
6. (GPUマシンの場合) GPUの設定  
7. dockerのインストール  
8. (GPUマシンの場合) nvidia-docker2のインストール  

***
# 1. インストールディスクの準備
8GB以上のUSBメモリを用意して, [ここ](http://www.ubuntulinux.jp/News/ubuntu2004-ja-remix)からDLしたデータをrufus辺りで書き込む.  
色々手段がありアップデートされているのでテキトーにwebから見繕う, [ここら辺](https://diagnose-fix.com/topic2-003/)参照.  

***
# 2. インストール
## (1) BIOS/UEFIの起動
↑で作成したUSBを対象のマシンに差込み, BIOS/UEFIを起動して入る.  
BIOS/UEFIはピットフォールがままあるが, だいたいはF1, F2, F12, del辺りをぴこぴこ押していれば入れる.  

## (2) bootディスクの優先度変更
BIOS/UEFIに入ったら起動の優先順を変更する.  
作成したUSBを最優先, 起動用のSSDを2番手にする.  
他に保管用HDDが入っている場合等は注意する.  
適宜画面に従い, 保存して終了すると次に進む.  

## (3) インストール
あとは画面指示に従って進めるだけ.  
二点ほど気を付ける.  
- 元々Ubuntuが入っている場合  
    - 序盤の方でどこに入れるか聞かれるので気をつける  
    - 以前入っているubuntuを上書きするみたいな選択肢を選ぶ  
- USBを抜く  
    - インストール後再起動する際にUSBを抜くように指示されるので抜く  
    - 放っておくと進まない  

***
# 3. ネットワークの設定
基本的にホストマシンはgnomeを使ったGUIにしているので, 普通にGUIとしてネットワーク設定を行う.  
右上ら辺のアイコンをクリックして優先接続の設定を行う.  

***
# 4. セキュリティの設定
```1_UbuntuSecurity.md```を参照して以下のセキュリティ設定を行う.  
1. ufwの設定  
2. sshdの設定 
3. clamavの導入  
鍵の作り方等は```1_UbuntuSSH.md```を参照.  
各人自身の秘密鍵・公開鍵ペアを計算機サーバーごとに作成し, それぞれの計算機サーバー公開鍵を加える形をとっている.  


***
# 5. ディスクのマウント
起動ディスクとしてのSSD以外にだいたいはデータ保管用のHDDも入れている.  
そのままだと認識してくれないので, ```1_UbuntuHDD.md```を参照してマウントする.  
HDDの中身を消したくない場合には, マウントポイントの作成から始めればよいはずだが, その後起動時の自動マウントが効いていないような気もする…？(220109)  
この場合, 都度```$ sudo mount /dev/sda /mnt/data1```などとマウントする必要があって面倒.  

***
# 6. GPUの設定
GPUマシンの場合のみ行う.  
nvidia-driverの導入とcudaのインストールを行う.  
更新が早いため最新の情報に気を配る.  
[この辺り](https://qiita.com/porizou1/items/74d8264d6381ee2941bd)を参考にする.  

## (1) 使用しているGPUの確認
```lcpci | grep -i nvidia```

## (2) 現状入っているものの確認・削除

    $ dpkg -l | grep nvidia
    $ dpkg -l | grep cuda
    $ sudo apt-get --purge remove nvidia-*
    $ sudo apt-get --purge remove cuda-*

## (3) nvidia-driverのインストール
```ubuntu-drivers devices```で推奨のドライバ (recommended) を確認した後, 以下を実行  

    $ sudo add-apt-repository ppa:graphics-drives/ppa
    $ sudo apt update
    $ sudo apt install nvidia-driver-{推奨されたバージョン}
    $ sudo reboot # 再起動が必要

最後に```nvidia-smi```でそれっぽい表示が返ってくればOK.  

## (4) cudaのインストール

    $ wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
    $ sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
    $ sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
    $ sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
    $ sudo apt-get update
    $ sudo apt-get -y install cuda

## (5) bashrcにパス追加

    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

最後にバージョン確認して完了.  
```$ nvcc -V```


***
# 7. docker/docker-composeのインストール
更新が早いため最新の情報に気を配る.  
## (1) dockerのインストール

    $ curl https://get.docker.com | sh
    $ sudo systemctl start docker && sudo systemctl enable docker
    $ sudo usermod -aG docker $USER
    $ docker -v
    $ sudo apt install docker-compose
    $ docker-compose -v

## (2) docker-composeのインストール
シンプルにaptを使うとversionが古くてハマる.  
```snap```を用いた方がバージョンは新しいがあんまり情報を見ない.  
なので[公式](https://docs.docker.com/compose/install/)に従ってバイナリからインストールする.  

    $ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    $ sudo chmod +x /usr/local/bin/docker-compose
    $ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose # そのままだとlocalにパスが通っていないのでシンボリックリンクを張る
    $ docker-compose --version


↑一行目のdownload後, versionに当たる部分は適宜変更が必要になりそう.  

***
# 8. (GPUマシンの場合) nvidia-docker2のインストール
更新が早いため最新の情報に気を配る.  
おそらく上記に続いたdocker daemonが動いている状況で行うべき.  
[公式](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#installing-docker-ce)が参考になる.  

    $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    $ sudo apt-get update
    $ sudo apt-get install -y nvidia-docker2
    $ sudo systemctl restart docker
    

上記の後, 一度再起動してから確認してそれっぽい画面が出ればOK  

    $ sudo reboot
    $ sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi # 確認用

