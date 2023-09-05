# 計算機にUbuntuを導入してセットアップする (Ubuntu20.04)

1. Ubuntuインストール
    1. インストールメディアを作成する
        - ローカル側PCで行う
        - 使用していないUSBが望ましい
        1. Ubuntu OSをダウンロードする [https://www.ubuntulinux.jp/News/ubuntu2004-ja-remix]
            - ISOファイルを選択する
        1. [Rufus](https://rufus.ie/ja/)をインストールし、起動可能なUSBを作る
    1. マシンの電源を切り、USB等で作成したインストールメディアを接続する
    1. Biosに入り、"Boot"から起動順を変えてUSBが先頭になるようにする
        1. 起動画面でBIOSに入るためのコマンドが表示されるので従って連打する(1回でも入れるが連打しておくと確実)
            - 表示されない場合は会社ごとに違うことが多いので調べる
        1. (optional)"Secure Boot" を Windows → Other OSに変更
        1. "Save change and reset"から保存して再起動
    1. インストーラーに従ってインストール
        - もともとUbuntuが入っているマシンの場合、基本的には元のUbuntuを上書きする選択肢を選ぶ。併設はパーティションの設定が厄介
        - インストール後は再起動前にインストールメディアを抜く


1. ネットワーク設定
    1. `ip link`からデバイス名を取得
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
            addresses: [xxx.xxx.xxx/xx]  # IPアドレス
            gateway4: yyy.yyy.yyy 
            nameservers:
                addresses: [aaa.aaa.aaa, bbb.bbb.bbb]  # DNSサーバー(優先, 代替)
        ```
        ``` shell
        sudo netplan apply
        ```
        - GUIでもできるがnetplanを使用しておくとメンテナンスしやすい

    
1. セキュリティ設定
    1. ufwを設定する
        ``` shell
        $ sudo apt install ufw
        $ sudo ufw default deny
        $ sudo ufw allow from xxx.xxx.xxx/xx to any port 49152  # SSHで使用するポートを開放する  # 53,80,443,49152のポートをそれぞれ開ける
        $ sudo ufw limit 49152
        $ sudo ufw enable
        ```

    1. clamavを設定する
        ``` shell
        $ sudo apt install clamav clamav-daemon
        $ sudo rm -rf /var/log/clamav/freshclam.log
        $ sudo touch /var/log/clamav/freshclam.log
        $ sudo chown clamav:clamav /var/log/clamav/freshclam.log
        $ sudo vim /etc/logrotate.d/clamav-freshclam
        ```
        ``` viml
        # create 640 clamav adm を変更
        create 640 clamav clamav
        ```
    1. clamavでウイルススキャンする
        ``` shell
        $ sudo freshclam
        $ clamscan -i -r /var
        $ clamscan -i -r /home
        $ clamscan -i -r /opt
        ```
        - 定期的に行う

1. SSH設定
    SSHsetup.mdを参照

1. GPU/docker設定
