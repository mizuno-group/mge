# SSH接続

## SSHとは？

Secure Shellの略。ネットワークを介した遠隔操作のためのプロトコル。サーバー側はSSHデーモン、クライアント側ではSSHクライアントというソフトを起動し、通信を行う。Linuxの場合はデフォルトで起動されている。

確認コマンド

```
$ ssh -v
```

二つの認証方式が存在。

1. パスワード認証方式

サーバー側のユーザーにユーザー名とパスワードでログイン。

2. 公開鍵認証方式

クライアント側で作成した公開鍵をサーバー側に登録し、秘密鍵により認証。

## 導入方法

今回は公開鍵認証方式の導入法（クライアント:Windows10, サーバー: CentOS8）について書く。

### クライアント側

1. 鍵の作成

https://qiita.com/digdagdag/items/9e5c061e7d86e0af9a57

上記を参考にした。

```
mkdir c:\Users\XXXXX\.ssh
```

powershellで入る。

```
PS C:\Users\XXXXX> ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (//.ssh/id_rsa): c:/Users/XXXXX/.ssh/id_rsa
Enter passphrase (empty for no passphrase):
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

```id_rsa```と```id_rsa.pub```が```c:/Users/XXXXX/.ssh```内に生成される。

### サーバー側

https://qiita.com/picor/items/8823ecef51bf2aff327c
を参考にした。

#### セキュリティアップデート(インストール)

##### Ubuntuの場合

```
$ sudo apt install openssh-server
```

SSHソフトインストール。

##### CentOSの場合
```
$ sudo yum update openssh
```

この後の操作は共通。

```
$ sudo systemctl start ssh
```

これでSSHサーバーが立ちあがる。

#### 公開鍵のアップロード

次に~/.sshディレクトリに移動する。

```
$ cd ~/.ssh
$ ls
```

ここでディレクトリ内に```authorized_keys```が存在するか確認。

①ある場合

```
$ cat id_rsa.pub >> authorized_keys
```
この```id_rsa.pub```はUSBなどで移した公開鍵。

②ない場合
```
$ mv id_rsa.pub authorized_keys
$ chmod 600 authorized_keys
```

#### sshd_configの設定

```
$ sudo vi /etc/ssh/sshd_config
```

ポートの変更。デフォルトのport 22は狙われやすいため。ここでは49152を選んだが、適宜空いているポートを見つける。

```
Port 49152 #デフォルト：#Port 22
```

ルートログインができないようにする。

```
PermitRootLogin no #デフォルト：PermitRootLogin yes
```

鍵認証をできるようにする。

```
PubkeyAuthentication yes #デフォルト：#PubkeyAuthentication no
```

パスワード認証ができないようにする。

```
PasswordAuthentication no #デフォルト：PasswordAuthentication yes
```

#### ファイヤーウォールの設定

##### Ubuntuの場合

ufwを用いる。[```Ubuntu/UbuntSecurity.md```](https://github.com/mizuno-group0/environment/blob/master/Ubuntu/UbuntuSecurity.md)を参照。

##### CentOSの場合

```
$ sudo firewall-cmd --add-port=49152/tcp --permanent
$ sudo firewall-cmd --reload
$ sudo firewall-cmd --list-port
49152/tcp
```

SELinuxの設定

```
$ sudo dnf install -y policycoreutils-python-utils
$ sudo semanage port --add --type ssh_port_t --proto tcp 49152
$ sudo semanage port --list | grep ssh
ssh_port_t                    tcp      49152, 22
$ sudo systemctl restart sshd
$ sudo systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat yyyy-MM-dd hh:mm:ss JST; ●h ●min ago
```

### 接続

```
PS > ssh [user name]@[ip address] -p 49152
```