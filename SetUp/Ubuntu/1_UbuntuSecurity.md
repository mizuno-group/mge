# Ubuntuのセキュリティ
## 220109更新 tadahaya

大きく以下の三つ.   
1. ufwの設定  
2. sshdの設定 
3. clamavの導入  

***
# 1. ufwの設定
Ubuntuのファイアウォールはufwを通じて操作する.  
ufwはiptableを簡易的に操作できるようにしたものである.  
[参考・簡易版](https://qiita.com/RyoMa_0923/items/681f86196997bea236f0)  
[参考・詳細版](https://server-network-note.net/2021/08/ubuntu-server-20-04-lts-firewall-ufw/)  
[参考・詳細版2](https://www.gadgets-today.net/?p=4754)  

以下のフローで実施する.  
1. インストール  
2. デフォルトポリシーdeny  
3. 特定ポートへのアクセス  
4. ブルートフォース対策  
5. 起動  

## 1. インストール
```
$ sudo apt update && sudo apt upgrade
$ sudo apt -y install ufw
```
↑のコマンドは既に他で実施済みなら不要.  

## 2. デフォルトのポリシーをdenyにする
``` $ sudo ufw default deny ```
元からdenyなので不要らしい。ただ、デフォルト設定が不変なものなのかわからないので念のため実行しておく。

## 3. 特定ポートへのアクセスを許可
以下で特定のIPから特定のポートへの接続を許可する.  
``` $ sudo ufw allow from [IP address] to any port [SSH port] ```
ラボでは薬学系研究科からのみのアクセスを許可するので以下のようにCIDER表記で設定。
``` $ sudo ufw allow from 133.11.48.0/24 to any port [SSH port] ```

[SSH port]部分は自分の選んだport番号で, 49152-65535から選ぶ.  
一般には以下のようになっており, 動的・私的ポート番号から選ぶ.  
初めて設定する際には水野に確認する.  
- システムポート番号 (0–1023)  
- ユーザーポート番号 (1024–49151)  
- 動的・私用ポート番号 (49152–65535)


## 4. ブルートフォース対策
limitでブルートフォースアタック対策を行う。
これにより、30秒間に6回指定のポートにアクセスしてきたIPの接続を一定時間拒否する。
``` $ sudo ufw limit [SSH port] ```

## 5. 起動
``` $ sudo ufw enable ```
動作確認は以下
```
$ sudo ufw status

状態: アクティブ

To                         Action      From
--                         ------      ----
[SSH port]                LIMIT       Anywhere

```
ここで、非アクティブと表示されたらうまく起動できてない。
逆に無効化するには``` $ sudo ufw disable ```コマンドを使う。  

## 既にあるルールの削除
``` $ sudo ufw delete [削除したいルールの番号] ```
ルール番号は、``` $ sudo ufw status numbered ```で確認できる。

***
# 2. sshdの設定
sshを導入した後, 使用ポートやらの設定を行っておく必要がある.  
詳細はSSHのssh_config.md参照.  
以下のフローで行う.  

1. openssh-serverのインストール  
2. sshd_configの設定  


## 1. openssh-serverのインストール
```
sudo apt install openssh-server
sudo systemctl start ssh
```

## 2. sshd_configの設定
vimで開いて編集する.  
```$ sudo vim /etc/ssh/sshd_config```
↑でsshd_configファイルがvimにより開かれる.  
適宜カーソルを動かして以下を編集していく.  
```i```でインサートモードに入ってから編集できる.  
保存時はescキーを押した後に```:wq```で上書き保存, ```:q```で変更なし保存.  
だいたいは```#```でコメントアウトされているので, コメントアウトを外して必要があれば書き換える感じ.  
vimがなければ```$ sudo apt install vim```でインストールする.  

### (1) ポートの変更
```1. ufwの設定```で設定したssh portを指定する.  
```Port 49152 #デフォルトは22, このままは非常に危険```

### (2) ルートログイン禁止
```PermitRootLogin no```

### (3) 鍵認証有効化
```PubkeyAuthentification yes```

### (4) パスワード認証禁止
```PasswordAuthentification no```

***
# 3. clamavの導入
セキュリティソフトであるclamavをインストールする.  
本来は常々監視したいところだが, 非常に重いらしいので時期ごとに行うこととする.  
権限やらの問題にバグがあるらしく？一度消してから作り直して権限与えてみたいなややこしいことをしている (220109でも解決していないのか…).  
## (1) インストールとログ管理

    $ sudo apt install clamav clamav-daemon
    $ sudo rm -rf /var/log/clamav/freshclam.log
    $ sudo touch /var/log/clamav/freshclam.log
    $ sudo chown clamav:clamav /var/log/clamav/freshclam.log
    
## (2) 続ログ管理2
clamav-freshclamを以下のように編集する.  
```$ sudo vim /etc/logrotate.d/clamav-freshclam```で開く.  
```i```でインサートモードに入った後以下の変更を加える.  
- before  
    - ```create 640 clamav adm #中段くらいにある```  
- after  
    - ```create 640 clamav clamav```  

## (3) ウィルススキャン
以下で実施する. 水野指示の下, 定期的に行う.  
とりあえずここら辺のフォルダだけでよいか.  
    
    $ sudo freshclam #ウィルスデータのアップデート
    $ clamscan -i -r /var
    $ clamscan -i -r /home
    $ clamscan -i -r /opt

