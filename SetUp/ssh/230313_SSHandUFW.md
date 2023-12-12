# Ubuntuのインストール方法
ここでは, 新しくセットアップした計算機をfilsevに接続する手順を説明します。 
Ubuntuを再インストールする場合も参照してください。

@ 子ノード  
1. HIEGMのMACアドレスを確認  
画面上端の黒い領域の右のほうにある3点のアイコンをクリック→有線接続の設定 を確認  
もしくは 設定→ネットワーク  
\[221227 トラブルシューティング\] Hiegm7の設定時, この3点のアイコンが表示されなかった。
原因を調べたところOSがNICを認識していないようだった。別のバージョンのUbuntuをインストールすることで解決した。
1. NMTUIの設定
	1. ターミナルで```$ nmtui```と実行
	1. 「接続の編集」を選択
	1. 「EtherNet」の「有線接続」を選択  
        　LANケーブルの差し込み口が複数ある場合, 選択肢がその分表示される。
	1. 以下の項目を変更する。IPv4の項目のみで, IPv6の設定は必要ない。
		- 「IPv4設定」を「自動」から「手作業」にする
		- 「アドレス」を「192.168.1.○○」にする。  
			　↑IPアドレスはまた使っていないものを設定時に決める。
		- 「ゲートウェイ」を「192.168.1.10」(=filsevのIP)に設定
		- 「DNSサーバー」を「133.11.225.117」と「133.11.225.126」の2つにする。
		- 「自動的に取得されたDNSパラメーターを無視」にチェック(スペースキー)をする。
	
		設定後「OK」を選択
	1. 最初の画面まで戻り, 「接続をアクティベート」を選択
	1. 3.で選択した「有線接続2」を選択し, アクティベートする。  
		…この段階ではアクティベートできない?  
		その場合, 4. のDHCPの設定を終えてからもう一度試す。
	1. 「終了」を押して戻る

1. ufwの設定  
参考:   
[environment/Ubunutu/UbuntuSecurity.md](https://github.com/mizuno-group00/environment/blob/master/Ubuntu/UbuntuSecurity.md)  
[environment/computer_cluster/220906_network.md(devブランチ)](https://github.com/mizuno-group00/environment/blob/dev/computer_cluster/220906_network.md)

	1. インストール
		```
		$ sudo apt -y install ufw
		```
	1. デフォルトのポリシーをdenyにする
		```
		$ sudo ufw default deny
		```
		元からdenyなので不要らしい。ただ, デフォルト設定が不変なものなのかわからないので念のため実行しておく。
	1. 特定ポートへのアクセスを許可
		```
		$ sudo ufw allow from 192.168.1.10 to any port [SSH port]
		$ sudo ufw limit [SSH port]
		```  
		[SSH port]は自分の選んだssh port番号(49152など)  
		今回はfilsevからのみアクセスさせるため, 1行目でアクセスを認めるIPアドレスを設定する。
		下の段はブルートフォースアタック対策をしている。
	1. 起動
		```
		$ sudo ufw enable
		```
	1. ワーカーノードの必須ポートを開ける。  
		以下のコマンドを実行する:
		```
		$ sudo ufw allow from 192.168.1.0/24 to any port 30000:32767 proto tcp
		```
        参考先の [environment/Ubunutu/UbuntuSecurity.md](https://github.com/mizuno-group00/environment/blob/master/Ubuntu/UbuntuSecurity.md)では他にも開けるポートがあるが, それらはKubernetes用なので現在は不要。
	1. ufwを起動する。
		```
		$ systemctl restart ufw
		```
	- ufwの動作確認は
		```
		$ sudo ufw status
		```
		で確認できる。ここで, incactiveと表示されたらうまく起動できてない。  
		逆に無効化するには, 
		```
		$ sudo ufw disable
		```
		コマンドを使う。
1. SSHサーバーの設定  
参考: [environment/SSH/SSH_config.md](https://github.com/mizuno-group00/environment/blob/dev/SSH/SSH_config.md)  
- まだインターネットに接続されていない場合, 後述の```$ sudo apt install …```などを実行できない。その場合, 次の「DHCPサーバーの設定」を先に行うか, 子ノードを直接有線接続する。  
子ノードを直接有線接続する場合は, 適当なIPアドレス(水野班の中で, まだ使っていないもの)を使用する。
	1. SSHサーバーをインストールする。
		```
		$ sudo apt install openssh-server 
		```

	1. SSHサーバーを立ち上げる
		```
		$ sudo systemctl start ssh
		```
	1. sshd_configを編集する。  
        ※ この時点ではviが使えるが, 操作性が悪いのでvimをインストールすることを推奨。
		```
		$ sudo vi /etc/ssh/sshd_config
		```
		- ポートの変更
			```
			Port 49152
			```
		- ルートログインできないようにする。
			```
			PermitRootLogin no
			```
		- 鍵認証できるようにする。
			```
			PubkeyAuthentication yes
			```
		- パスワード認証ができないようにする。
			```
			PasswordAuthentication no
			```
        - AuthorizedKeyのファイルを設定
            ```
            AuthorizedKeyFile /home/{ユーザー名(hiegm1　など)}/.ssh/authorized_keys
            ```
			\[221227 トラブルシューティング\] AuthorizedKeysFileを~/.ssh/authorized_keysにしたところ, ~がユーザー(hiegm7)ではなくrootのホームディレクトリと解釈されファイルが存在しないエラーになっていた。

@filsev  

5. DHCPの設定  
参考: [environment/computer_cluster/220906_network.md(devブランチ)](https://github.com/mizuno-group00/environment/blob/dev/computer_cluster/220906_network.md)  
- 子ノードにUbuntuを再インストールした場合, この設定はすでにされているため不要。
    1. filsevに移動  
	2. /etc/dhcp/dhcpd.confを編集  
		子ノードのMACアドレスと, 設定したいIPアドレスを書き加える。
        ```
        host {子ノードの名前} {
        hardware ethernet {子ノードのMACアドレス};
        fixed-address {割り当てるIPアドレス};
        }
        ```
        基本的にはすでに書かれている設定の通りに書けばよい。  
	3. dhcpdのリスタート  
        ```$ /etc/init.d/isc-dhcp-server restart```を実行  

6. filsev→HIEGM用のSSH鍵の作成
1. 公開鍵をHIEGM7のauthorized keysに書き込む。  
	参考: [environment/SSH/SSH_config.md](https://github.com/mizuno-group00/environment/blob/dev/SSH/SSH_config.md)
	1. ~/.sshディレクトリにauthorized_keysファイルがあるか確認
		ない場合は新しく作る。
	1. filsevで作成した公開鍵を書き込む。
	1. ファイルの権限を変更
		~~~
		sudo chmod 600 ~/.ssh/authorized_keys
		~~~