# SSH設定

## クライアント側の設定
1. 鍵を作成する
    ``` powershell
    > ssh-keygen -t rsa -b 4096
    Generating public/private rsa key pair.
    Enter file in which to save the key (/c/Users/user/.ssh/id_rsa):  # 鍵のファイル名を入力
    Enter passphrase (empty for no passphrase):  # パスワードを入力
    Enter same passphrase again:  # 再度入力
    Your identification has been saved in id_rsa
    Your public key has been saved in id_rsa.pub
    The key fingerprint is:
    SHA256:vnvvXm8s2157Jq+eure6IoQk2rrTjQGBvYhfzbWIp8Q user@MyComputer
    The key's randomart image is:
    +---[RSA 4096]----+
    | o               |
    |. o     .        |
    |.. + + o .       |
    |o o E * .        |
    | . * = .S        |
    |  o + ...        |
    |   o + ..     ...|
    |  o o . ..o  .++B|
    |  .o    o+ =OB*%*|
    +----[SHA256]-----+
    ```


## サーバー側の設定
1. sshサーバーをインストールして立ち上げる
    ``` shell
    sudo apt install openssh-server
    sudo systemctl start ssh
    ```
1. ローカルで作成した公開鍵を.ssh以下に移す
1. `ls .ssh`でauthorized_keysファイルが存在するか確認する
    - ない場合は、`touch ~/.ssh/authorized_keys`で作成し、`chmod 600 ~/.ssh/authorized_keys`で権限設定
1. 公開鍵を追加する
    ``` shell
    $ echo "#init" >> authorized_keys
    $ cat ~/.ssh/id_rsa_XXX.pub >> authorized_keys
    $ echo "#end" >> authorized_keys
    ```
1. /etc/ssh/sshd_configを編集する
    ``` conf
    Port zzz  #デフォルトは22だがそのままはセキュリティの不安があるため、49152以上の数が望ましい
    (略)
    PermitRootLogin no
    PubKeyAuthentication yes
    PasswordAuthentication no
    ```
1. 変更を反映する
    ``` shell
    $ sudo service sshd restart
    ```
    

## SSH接続
#### コマンドラインから接続する
``` shell
$ ssh -i C:\Users\user\.ssh\id_rsa_xxx -p zzz server_user@xxx.xxx.xxx
```
ポートフォワーディングをしたい場合は`-L [クライアント側ポート]:[サーバー名]:[サーバー側ポート]`を追加する
#### configを設定する
1. .ssh/configを作成する
    ``` config
    Host server_user
      HostName xxx.xxx.xxx
      User server_user
      Port zzz
      IdentityFile C:\Users\user\.ssh\id_rsa_XXX
      IdentitiesOnly yes
    ```
1. Configを設定すればHost名から接続することが可能
    ``` shell
    $ ssh server_user
    ```