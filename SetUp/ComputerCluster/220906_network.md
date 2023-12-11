# 220906 PC移動に際するクラスタ構築の注意点

- filsevとQNAPの接続
    1. filsevの電源を入れ、外部ネットワークを中部ポートに、QNAPに繋ぐケーブルを下部ポートにさす
    1. QNAPの電源を入れる
    1. filsevから出たケーブルを**前面のポート**のどこかに差す
    1. filsevのネットワーク設定のうち、**有線接続2を接続する**(もう1つのnet-enp1s0はフェイク)
    1. 192.168.1.11に入るとQNAPのページから各ポートの接続状況が確認できる
    1. 各子機とQNAPのポートをケーブルで繋ぐ

# 221018 HIEGM5 クラスタ構築時の手順  

### ① SSH接続の設定
1. filsevでsshキーを作成し, 公開鍵をUSBなどにコピーする。
1. HIEGM5(子ノード)に移動し, ssh公開鍵をauthorized_keysにコピーする
1. sshを再起動  
`$ systemctl restart ssh`
### ② HIEGM5のMACアドレスを確認
アクティビティ画面 → ネットワーク → 設定 で確認できる
### ③ イーサネットの設定
1. NMTUIを開く  
ターミナルで `$ nmtui` と実行
1. IPアドレスを変更
1. ゲートウェイをfilsevのIPアドレス (192.168.1.10) に変更
1. 「自動的に取得されたDNSパラメータを無視」
にチェック
1. 設定を反映する(activateする)

### ④ ポートを開ける
[Kubernetesの説明](https://github.com/mizuno-group00/environment/blob/master/kubernetes/kubernetes_doc.md)の「必須ポートを開ける」も参照(コントロールプレーンのポートを開ける必要はない)。  
1. ワーカーノードの必須ポートを開ける。  
以下の2つのコマンドを実行する:  

```bash
\$ sudo ufw allow from 192.168.1.0/24 to any port 10250  
\$ sudo ufw allow from 192.168.1.0/24 to any port 30000/32767 proto tcp
```

1. 1のコマンドを10.244.0.0/16に対しても行う。
1. ufwを再起動  
`$ systemctl restart ufw `

### ⑤DHCPの設定 @filsev  
1. filsevに移動
1. /etc/dhcp/dhcpd.confを編集  
子ノードのMACアドレスと, 設定したいIPアドレスを書き加える。すでに書かれている設定などを参照
1. dhcpdのリスタート  
$ /etc/init.d/isc-dhcp-server restart を実行  

この段階で, 正しく設定できていればfilsevから子ノードにSSH接続できる。
### ⑥ マウント (子ノードのみ記載)
1. nfs-commonをインストール
1. 子ノードのディレクトリを接続許可した親ノードディレクトリにマウント
`mount -t nfs {親ノードIP}:{親ノードのマウント先} {子ノードのマウント先}`


