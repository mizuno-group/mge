# Ubuntuの立ち上げ → ネットワーク設定 → 計算機クラスタ構築

全体の参考：[自作クラスタ計算機](http://www2.yukawa.kyoto-u.ac.jp/~koudai.sugimoto/dokuwiki/doku.php?id=%E8%87%AA%E4%BD%9C%E3%82%AF%E3%83%A9%E3%82%B9%E3%82%BF%E8%A8%88%E7%AE%97%E6%A9%9F:ip%E3%83%9E%E3%82%B9%E3%82%AB%E3%83%AC%E3%83%BC%E3%83%89%E3%81%AE%E5%9F%BA%E6%9C%AC%E8%A8%AD%E5%AE%9A)

## 親ノード(FILSEV)のセットアップ
- Ubuntu OSをイメージディスクからインストールする
　※イメージディスクの作成方法は[UbuntuInstallSummary.md](https://github.com/mizuno-group00/environment/blob/master/Ubuntu/0_UbuntuInstallSummary.md)を参照
    1. イメージディスクを差して起動し、BIOSに入る
        - Tsukumoの場合はdel or F2を連打
    1. 「Advanced Mode」→「Boot Option」から USB とある選択肢を一番上にする
- 再起動してセットアップ手順に従う
    - 今まで入っていたOSは削除するのが分かりやすい


## QNAPの設定
★すべてのネットワーク設定の前に行う
1. FILSEVのNICとQNAPを接続する
1. QNAPに割り当てられている(機器裏面に記載)IPアドレスにブラウザから入る
1. ログインを要求されるので、裏面のusernameとパスワードを入力
1. 「system settings」からIPを'Automatically'に変更する


## FILSEVのネットワーク設定
IP: 133.11.48.xxx
1. FILSEVにLANを差す
1. `ip link`からLANが差してあるポート名とMACアドレスを把握する
    - 差さっているポートは`state UP`と表示される
1. netplanからファイルを設定する
    ``` shell
    sudo vi /etc/netplan/[.yamlファイル]
    ```

    ``` yaml:~.yaml
    network:
      version: 2
      renderer: NetworkManager
      ethernets:
        eno1: #外部ネットワーク用ポート
          dhcp4: no
          dhcp6: no
          addresses: [133.11.48.xxx/23]
          gateway4: 133.11.48.1
          nameservers:
            addresses: [133.11.225.117, 133.11.225.126]
        enp1s0: #イントラ用ポート
          dhcp4: no
          dhcp6: no
          addresses: [192.168.1.10/24]
    ```

    ``` shell
    sudo netplan apply
    ping 8.8.8.8  # 接続の確認
    sudo apt update  # 接続を確認したらすぐに更新
    ``` 
    ※ ネットに繋がる前はvimがバグっている。一時的にファイル権限を777にするか、テキストエディタに書いてコピーするとよい

## DHCPの設定
- DHCPサーバーはクラスタ内の各ノードにプライベートのIPアドレスを割り振る

1. isc-dhcp-serverをインストール
1. /etc/default/isc-dhcp-serverを編集
    ``` viml:/etc/default/isd-dhcp-server
    (略)
    INTERFACESv4 = "enp1s0"
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

        host filsev{
        hardware ethernet xx:xx:xx:xx:xx:xx;    # MACアドレス
        fixed-address 192.168.1.10;
        }
        host [QNAP型番]{
            (略)
        }
        ...
    }
    ```
1. サーバーを再起動
    ``` shell
    sudo systemctl restart isc-dhcp-server
    ping 192.168.1.xx   # イントラ側に対して接続確認
    ```

/# 2022年でISC=DHCP-SERVERの開発が終了しているらしく、Kea-DHCPに移行されるらしい。ubuntu22.04移行時に検討したい。


## FILSEVのufw設定・IPマスカレード
- IPマスカレードはクラスタ内から外部のネットワークに繋ぐために必要
- 以前はiptablesによる煩雑な操作が必要だったが、現在はufwで簡易的に設定可能

1. ufwをインストール
1. デフォルトポリシーを変更する
    ``` shell
    sudo ufw default deny
    ```
1. 53,80,443,49152のポートをそれぞれ開ける
    ``` shell
    sudo ufw allow from 133.11.48.0/24 to any port 53
    # 他のポートについても同様
    sudo ufw limit 49152    #ブルートフォースアタック用
    ```
1. クラスタからの通信を許可する
    ``` shell
    sudo ufw allow from 192.168.1.0/24
    ```

1. ポートフォワードを有効にする
    ``` viml:/etc/default/ufw
    DEFAULT_FORWARD_POLICY="ACCEPT"
    ```
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
    49152                      ALLOW       133.11.48.0/24
    49152                      LIMIT       Anywhere
    443                        ALLOW       133.11.48.0/24
    80                         ALLOW       133.11.48.0/24
    53                         ALLOW       133.11.48.0/24
    Anywhere                   ALLOW       192.168.1.0/24
    49152 (v6)                 LIMIT       Anywhere (v6)
    ```


## 子ノード(HIEGM)のネットワーク設定・ufw設定 (親のDHCP設定と並行して行う)
1. `ip link`からデバイス名とMACアドレスを取得　→　MACアドレスは親ノードの設定に使う
1. netplanを編集する
    ``` yaml:/etc/netplan/01-network-manager-all.yaml
    network:
      version: 2
      renderer: NetworkManager
      ethernets:
        eno2: # ip linkで検索したデバイス名
          dhcp4: no
          dhcp6: no
          addresses: [192.168.1.xx/24]
          gateway4: 192.168.1.10
          nameservers:
            addresses: [133.11.225.117, 133.11.225.126]
    ```
    ``` shell
    sudo netplan apply
    ```
1. ufwを設定する
    ``` shell
    sudo apt install ufw
    sudo ufw default deny
    sudo ufw allow from 192.168.1.0/24 to any port 49152
    sudo ufw limit 49152
    sudo ufw enable
    ```

- ping で google.com につないで設定が機能していることを確認する


## ssh設定
1. sshサーバーをインストールして立ち上げる
    ``` shell
    sudo apt install openssh-server
    sudo systemctl start ssh
    ```
1. HIEGMのconfigを編集する
    ``` conf:/etc/ssh/sshd_config
    Port 49152
    (略)
    PermitRootLogin no
    PubKeyAuthentication no
    PasswordAuthentication yes
    PermitEmptyPasswords yes
    ```
    ※親ノード→子ノードは鍵のないssh接続とする。子ノードのログインパスワードを入力することでssh接続可能になる 


## hostファイル編集
FILSEVの/etc/hostsを編集する
``` viml:/etc/hosts
127.0.0.1       localhost
127.0.1.1       filsev
192.168.1.xx    filsev
192.168.1.yy    hiegm
```


## NFSの設定
参考：[Linux – NFS でリモートマシンのディレクトリをマウントする](https://pystyle.info/linux-how-to-mount-directory-on-another-machine/#outline__3)  
1. HDDをマウントする
    ``` shell
    sudo fdisk -l # deviceを確認
    sudo mkfs.ext4 /dev/xxx # 上で選んだdeviceを選択
    mkdir /mnt/{名前}
    ls -l /dev/disk/by-uuid # マウントしたdeviceのUUIDを取得
    sudo vi /etc/fstab
    ```
    ``` viml:/etc/fstab
    UUID=[UUID] /mnt/local ext4 defaults 0 0
    ```
　　

(FILSEV側の設定)
1. nfs-kernel-serverをインストール
1. ファイルを編集する
    ``` viml:/etc/exports
    /mnt/data_filsev 192.168.1.0/255.255.255.0(rw,async,no_root_squash)
    #マウント先ディレクトリ, マウント元IP(オプション)
    ```

1. NFSを再起動する
    ``` shell
    sudo systemctl restat nfs-kernel-server
    ```

(HIEGM側の設定)
1. nfs-commonをインストール
1. ファイルを編集する
    ``` viml:/etc/fstab
    192.168.1.10:/mnt/data_filsev /mnt/data nfs defaults
    # マウント先IP:ディレクトリ, マウント元ディレクトリ, 接続形式
    ```
1. マウントする
    ``` shell
    sudo mount -a
    ```

※ (230317) 再起動後にNFSが自動接続しないため、都度マウントする  
※ /usr/localや/optをマウントするとソフトウェアも共有可能らしい













