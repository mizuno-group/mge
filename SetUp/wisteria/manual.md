# Wisteriaの環境構築

## Flow
1. sshの接続確立
1. 基本操作
1. Python環境のtest
1. Build your own code

***
## sshの接続の確立
1. opensshのinstall  
* 基本的にLINUX machineやWindowsには既に入っているはず。省略する。

2. ssh-keyの生成
* 普段計算機に接続する際と同様。
```
PS CD> ssh-keygen -t rsa -b 4096 # 4096 bitにしておく
Generating public/private rsa key pair.
Enter file in which to save the key (C:\Users\Katsuhisa Morita/.ssh/id_rsa): c:\docker\.ssh\id_rsa_wisteria
Enter passphrase (empty for no passphrase): # 空でよいか？
Enter same passphrase again: # 空でよいか？
Your identification has been saved in c:\docker\.ssh\id_rsa_wisteria.
Your public key has been saved in c:\docker\.ssh\id_rsa_wisteria.pub.
The key fingerprint is:
SHA256:BizDxO75e05/xtWNLdTCOJeVG7TuoFVSDf/63JDS4Xg katsuhisa morita@MyComputer
The key's randomart image is:
+---[RSA 4096]----+
|   ..         o+o|
|   o..        .++|
|   .+ o      + *+|
|    .o .    o X.o|
|   . .  S    *.*o|
|    o  .    o+*++|
|     .  .  oo.Eo |
|      ....  +o +.|
|      .+. .o    +|
+----[SHA256]-----+
```

3. Wisteria Portalサイトにアクセスし、鍵を登録する
* [Wisteria Homepage](https://www.cc.u-tokyo.ac.jp/supercomputer/wisteria/service/) → 利用支援ポータル
* 適宜パスワードは管理する。最初使用するときは初期化する（一敗）。
* SSH公開鍵登録に移行
* ファイルアップロードより、id_rsa_wisteria.pubをアップロードする

4. powershell、MobaXterm等よりsshでアクセスできることを確認  
* wisteria.cc.u-tokyo.ac.jpに接続する  
* 鍵認証しているので以下の感じ: ```ssh -i {秘密鍵のパス} {利用者ID}@wisteria.cc.u-tokyo.ac.jp```  
    * 具体例: ```ssh -i C:\Users\tadahaya\.ssh\id_rsa_wisteria a97000@wisteria.cc.u-tokyo.ac.jp```  

***
## 基本操作
1. フォルダー構造
```
-home
    -[User] # 最初にいるところ。容量が少ないので使わない（使えない、エラーが出る）
-work
    -[ProjectCode]
        -[User1] # ここを基本的に使用する
        -[User2]
        -share
```

2. ファイル移動
* fileを送信
```
# file.csvをUserの直下に移動
scp D:/xxx/file.csv [User]@wisteria.cc.u-tokyo.ac.jp:/work/[ProjectCode]/[User]/
# folderを中身ごとUserの直下に移動
scp -r D:/xxx/folder [User]@wisteria.cc.u-tokyo.ac.jp:/work/[ProjectCode]/[User]
```
* fileを受信
```
# file.csvをxxx直下に移動
scp [User]@wisteria.cc.u-tokyo.ac.jp:/work/[ProjectCode]/[User]/file.csv D:/xxx/ 
# folderを中身ごとxxx直下に移動
scp -r [User]@wisteria.cc.u-tokyo.ac.jp:/work/[ProjectCode]/[User] D:/xxx/
```
* もちろんMobaXtermのGUIでも操作できる。そっちのほうが私は楽。

***
## Python環境のtest
1. 簡単なtestをしたい場合
```
 pjsub --interact -L rscgrp=interactive-a,node=1 -g [ProjectCode]
```
* これでinteracticeなものが立ち上がる

2. MNIST x Pytorch
```
 pjsub test_pytorch.sh
```
* PytorchでMNISTの簡単なNeuralNetの予測
* .pyの中身のa97001を自分のfolderに変える必要有。

***
## Build your own code
1. memo
* 基本的にtest_pytorch.shを見て適宜動かしてほしい
* 環境自体は自分のfolder直下に作成されるので、mvenvを毎回作成する必要はない。
* moduleのリセットの有無は不明

2. Options
* ```#PJM -L rscgrp=debug-a``` のようにsh fileの最初に指定する、またはpjsubの際に指定
* rscgrp=regular-a/debug-a/interactive-a/: 必須、複数タスクの場合はa→o?
* node=1: ノードの数（ノード占有利用の場合）
* gpu=1: GPUの数（GPU専有利用の場合）
* elapse=0:10:00: 経過時間が指定時間を過ぎたら強制終了
* -g [ProjectCode]: 必須

***
## Note
* [221026 morita] print()するとfile.jobnumber.outに出力される
* errにも何かが出てるけどどの基準でそっちに行っているかが全くわからない。