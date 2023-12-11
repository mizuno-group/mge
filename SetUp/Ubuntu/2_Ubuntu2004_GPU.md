# Ubuntu 20.04でのGPU環境（miniconda + PyTorchの構築）

## ダウンロード

http://www.ubuntulinux.jp/News/ubuntu2004-ja-remix

よりダウンロード。

rufusを用いてUSBメモリに書き込み。

## インストール

saveモードで起動。これをしないと起動できないことがある。すべてデフォルトで基本的にはOK。

## ネットワーク設定

IPアドレス、サブネットマスク、デフォルトゲートウェイ、DNSサーバーIPを設定。

## UFW設定

```UbuntuSecurity.md```を参考にして、ファイアウォールを設定する。

## SSH設定

```SSH_config.md```を参考にしてSSH接続の設定を行う。公開鍵秘密鍵のペアは各自1台のクライアントにつき1組用意する。

## Dockerのインストール

```UbuntuDockerInstallation.md```を参考にする。

## GPUドライバーのインストール

リポジトリのインストール

```
$ sudo add-apt-repository ppa:graphics-drivers/ppa
$ sudo apt update
```

推奨ドライバーの確認

```
$ ubuntu-drivers devices
== /sys/devices/pci0000:00/0000:00:03.1/0000:0d:00.0 ==
modalias : pci:v000010DEd00001F07sv00001043sd00008670bc03sc00i00
vendor   : NVIDIA Corporation
model    : TU106 [GeForce RTX 2070 Rev. A]
driver   : nvidia-driver-440 - distro non-free recommended
driver   : nvidia-driver-435 - distro non-free
driver   : xserver-xorg-video-nouveau - distro free builtin
```

推奨ドライバーを直接インストール

```
sudo apt install nvidia-driver-440
```

## GPU docker

```
docker: Error response from daemon: linux runtime spec devices: could not select device driver "" with capabilities: [[gpu]].
```

というエラーが出る場合。

どこでもいいので、下記を```nvidia-container-runtime-script.sh```という名前で保存

```
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
```

そのあと

```
$ sh nvidia-container-runtime-script.sh
```

を実行。

```
$ sudo apt-get install nvidia-container-runtime
```

これでnvidia-container-runtimeをインストールできる。

```
$ systemctl restart docker.service 
```

上記でdockerを再起動すればエラーが消えるはず。