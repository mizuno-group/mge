# Ubuntuマシンのクラスター化
親ノード1台からマネージドスイッチを介して複数台の子ノードに接続し、親ノードへのssh接続のみで全ての子ノードへssh接続可能にすることを目的とする。

#### terminology
親ノードの固定IP: xxx.xxx.xxx/xx  
デフォルトゲートウェイ: yyy.yyy.yyy  
子ノードIP: 192.168.1.yy  
親ノードユーザー名: parent  
子ノードユーザー名: child1, child2, ...  
DNS: zzz.zzz.zzz

## 親ノードのセットアップ
UbuntuSetup.mdを参照

## マネージドスイッチ(QNAP社製)設定
★すべてのネットワーク設定の前に行う
1. 親ノードのスイッチ側ポートとマネージドスイッチを接続する
1. マネージドスイッチに割り当てられている(機器裏面に記載)IPアドレスにブラウザから入る
1. ログインを要求されるので、裏面のusernameとパスワードを入力
1. 「system settings」からIPを'Automatically'に変更する

## 親ノードネットワーク設定
1. 親ノードのインターネット側ポートに有線LANを接続する
1. `ip link`からLANが差してあるポート名とMACアドレスを把握する
    ``` shell
    $ ip link

    1. lo: <LOOPBACK,UP,LOWER_UP> ~~~ 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2. eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> ~~~ state UP # ←接続済みのポート
        link/ether XX.XX.XX.XX.XX.XX brd ff:ff:ff:ff:ff:ff
        altname enp0s1111
    3. enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> ~~~ state DOWN
        link/ether YY.YY.YY.YY.YY.YY brd ff:ff:ff:ff:ff:ff
    ```
1. netplanからファイルを設定する
    ``` yaml:~.yaml
    network:
      version: 2
      renderer: NetworkManager
      ethernets:
        eno1: # 外部ネットワーク側ポート
          dhcp4: no
          dhcp6: no
          addresses: [xxx.xxx.xxx/xx]
          gateway4: yyy.yyy.yyy
          nameservers:
            addresses: [zzz.zzz.zzz] # 2つ以上あるときはカンマで区切る
        enp1s0: # スイッチ側ポート
          dhcp4: no
          dhcp6: no
          addresses: [192.168.1.aa/24]
    ```

    ``` shell
    $ sudo netplan apply
    $ ping 8.8.8.8  # 接続の確認
    $ sudo apt update  # 接続を確認したら更新を入れておく
    ```
    ※ ネットに繋がる前はvimがバグっている。一時的にファイル権限を777にするか、テキストエディタに書いてコピーするとよい

## DHCP設定
- DHCPサーバーはクラスタ内の各ノードにプライベートのIPアドレスを割り振る

1. isc-dhcp-serverをインストール
1. /etc/defaults/isc-dhcp-serverを編集
    ``` viml:/etc/default/isc-dhcp-server
    (略)
    INTERFACESv4 = "enp1s0" # イントラ用ポート
    INTERFACESv6 = "enp1s0"
    (略)
    ```
1. dhcpd.confを編集
    ``` conf:/etc/dhcp/dhcpd.conf
    authoritative;  # コメントアウトを削除
    (略)
    subnet 192.168.1.0 netmask 255.255.255.0 {
      option routers 192.168.1.1;
      option broadcast-address 192.168.1.255;

        host parent{
        hardware ethernet XX.XX.XX.XX.XX.XX;    # MACアドレス
        fixed-address 192.168.1.yy;  # 親ノードにもプライベートIPを割り当てる
        }
        host [マネージドスイッチ型番]{
            (略)
        }
        # クラスタ化したい子ノードについて全て記述する
        host child1{
            (略)
        } 
        ...
    }
    ```
1. サーバーを再起動
    ``` shell
    $ sudo systemctl restart isc-dhcp-server
    $ ping 192.168.1.yy   # 子ノード側に対して接続確認
    ```
※ 2022年でISC-DHCP-SERVERの開発が終了しているらしく、Kea-DHCPに移行されるらしい。ubuntu22.04移行時に検討したい。

## 親ノードIPマスカレード設定
- IPマスカレードはクラスタ内から外部のネットワークに繋ぐために必要
- 以前はiptablesによる煩雑な操作が必要だったが、現在はufwで簡易的に設定可能

1. ufwをインストール
1. デフォルトポリシーを変更する
    ``` shell
    $ sudo ufw default deny
    ```
1. 53,80,443,49152のポートをそれぞれ開ける
    ``` shell
    $ sudo ufw allow from 133.11.48.0/24 to any port 53  # 他のポートについても同様
    $ sudo ufw limit 49152    #ブルートフォースアタック用
    ```
1. クラスタからの通信を許可する
    ``` shell
    $ sudo ufw allow from 192.168.1.0/24
    ```

1. ポートフォワードを有効にする
    1. /etc/default/ufw
        ``` viml:/etc/default/ufw
        DEFAULT_FORWARD_POLICY="ACCEPT"
        ```
    1. /etc/ufw/sysctl.conf
        ``` conf:/etc/ufw/sysctl.conf
        net/ipv4/ip_forward=1
        ```
1. マスカレードをルールに登録する  
    「*filter」より上か、「COMMIT」より下に下記を追加する
    ``` viml:/etc/ufw/before.rules
    # NAT
    *nat
    -F
    :POSTROUTING ACCEPT [0:0]
    -A POSTROUTING -s 192.168.1.0/24 -o eno1 -j MASQUERADE
    COMMIT
    ```
1. ufwを起動する
    ``` shell
    $ sudo ufw enable

    $ sudo ufw status
    Status: active

    To                         Action      From
    --                         ------      ----
    49152                      ALLOW       xxx.xxx.xxx/xx
    49152                      LIMIT       Anywhere
    443                        ALLOW       xxx.xxx.xxx/xx
    80                         ALLOW       xxx.xxx.xxx/xx
    53                         ALLOW       xxx.xxx.xxx/xx
    Anywhere                   ALLOW       192.168.1.0/24
    49152 (v6)                 LIMIT       Anywhere (v6)
    ```

## 子ノードネットワーク・セキュリティ設定
1. `ip link`からデバイス名とMACアドレスを取得　→　MACアドレスは親ノードの設定に使う
1. netplanを編集する
    - /etc/netplan に yaml ファイルが存在するので書き換える
    ``` yaml:/etc/netplan/01-network-manager-all.yaml
    network:
      version: 2
      renderer: NetworkManager
      ethernets:
        eno2: # ip linkで検索したデバイス名
          dhcp4: no
          dhcp6: no
          addresses: [192.168.1.xx/24]
          gateway4: 192.168.1.yy  # 親ノードに割り振られたプライベートIP
          nameservers:
            addresses: [zzz.zzz.zzz]
    ```
    ``` shell
    $ sudo netplan apply
    ```
1. ufwを設定する
    ``` shell
    $ sudo apt install ufw
    $ sudo ufw default deny
    $ sudo ufw allow from 192.168.1.0/24 to any port 49152
    $ sudo ufw limit 49152
    $ sudo ufw enable
    ```
    ping で google.com につないで設定が機能していることを確認する

## ssh設定
SSHsetup.md を参照

※ 親ノード → 子ノードは鍵のないssh接続とする。子ノードのログインパスワードを入力することでssh接続可能になる
``` conf
Port 49152
(略)
PermitRootLogin no
PubKeyAuthentication no
PasswordAuthentication yes
PermitEmptyPasswords yes
```

## 親ノードhostファイル設定
/etc/hostsを編集する
``` viml
127.0.0.1       localhost
127.0.1.1       parent
192.168.1.xx    parent
192.168.1.yy    child1
```

## NFS設定
1. HDDのマウント
    ``` shell
    $ sudo fdisk -l  # device確認
    $ sudo mkfs.ext4 /dev/xxx  # 上で選んだdeviceを選択
    $ mkdir /mnt/{名前}
    $ ls -l /dev/disk/by-uuid  # マウントしたdeviceのUUIDを取得
    $ sudo vi /etc/fstab
    ```
    ``` viml
    UUID=[UUID] /mnt/local  ext4    defaults    0   0
    ```

(親ノード側の設定)
1. nfs-kernel-server をインストール
1. /etc/exportsを編集
    ``` viml
    /mnt/local 192.168.1.0/255.255.255.0(rw,async,no_root_squash)
    # マウント先ディレクトリ, マウント元IP
    ```
1. NFSを再起動する
    ``` shell
    $ sudo systemctl restart nfs-kernel-server
    ```
(子ノード側の設定)
1. nfs-commonをインストール
1. /etc/fstabを編集
    ``` viml
    192.168.1.xx:/mnt/local /mnt/local/HDD1 nfs defaults
    # マウント先IP:ディレクトリ, マウント元ディレクトリ, 接続形式
    ``` 
1. マウントする
    ``` shell
    $ sudo mount -a
    ```

※ (230317) 再起動後にNFSが自動接続しないため、都度マウントする  
※ /usr/localや/optをマウントするとソフトウェアも共有可能らしい