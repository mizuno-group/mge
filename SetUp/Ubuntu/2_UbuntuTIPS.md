# ■ 内容
Ubuntuをインストールした際の備忘用 (2020/9/10)  

***
# ■ インストール時
* BIOS/UEFIに入れない時  
ThinkStationはなぜかdisplayとの相性次第でUEFIが表示されない自体に陥る.  
F1 / F2 / F12連打で運が良いとUEFIに入れた.  
同じdisplayポートでも通るポートと通らないポートがあるかもしれない.  

* Third party  
適当にpasswordを設定すればよい

***
# ■インストール完了直後
* 再起動
この時USBメモリから読み込むようにBIOS設定されているため, 必ずF1,F2,F12,del辺りを連打してBIOS/UEFIに入るようにする.  
出遅れたら強制終了してBIOSに入り直す.  
Ubuntuをインストールしたディスクを優先的に読み込む設定へと変更する.

* ネットの設定
gnome desktopで入っている場合は簡単.  
普通にネットの設定をすればいい, 

***
# ■ インストール後
## aptのアップデート
どうやらubuntuはインストール直後はrootのパスワードが存在せず、rootでログインできないらしい.  
aptをupdateしておく.  
    ```
    apt update apt
    apt upgrade apt
    '''


## セキュリティソフトのインストール
Linuxでよく用いられているClamAVのインストールと設定.  
[参考](https://www.infocircus.jp/2019/10/05/centos-7-virusscan-clamav/)がわかりやすい.  
1. インストール
    
    ```
    sudo apt install clamav clamav-daemon
    ```

2. キャッシュ？の削除
    ```
    sudo rm -rf var/log/clamav/freshclam.log
    sudo touch /var/log/clamav/freshclam.log
    sudo chown clamav:clamav /var/log/clamav/freshclam.log
    sudo nano /etc/logrotate.d/clamav-freshclam
    ```
nanoに入った後
    ```
    create 640 clamav adm
　　↓
    create 640 clamav clamav
    ```
3. ウイルスデータのアップデート  
```freshclam```
  
4. 適宜スキャン
    
    ```
    clamscan --infected --recursive /var
    clamscan --infected --recursive /home
    clamscan --infected --recursive /opt
    ```

## その他セキュリティ
[ここ](https://qiita.com/Trouble_SUM/items/8591d7388cd7c0a792bc)が参考になる.  

### rootログインの無効化
* Ubuntuだと必要ない？
* Ubuntu のデフォルト設定では root ユーザーはパスワードが設定されていないため利用不可となっています
[参考](https://www.server-world.info/query?os=Ubuntu_20.04&p=initial_conf&f=2)

### firewallの設定
* sudo ufw enable; sudo ufw default deny; sudo ufw status verbose
* もしかしたらTeamViewerに影響が出るかもしれないのでoffのほうがいいかもしれない（要チェック）

***
# その他
### error報告
* Thinkstationのfiemwareのupdateをubuntuのupdaterから行ったところ  
  secure boot violationが起動時に表示されるようになった.  
  Enterで起動するようにはなったが、どこかはやばくなっていると思う  
  200911 Morita 

* LTSTA1が再起動後、起動しなくなった。以下の手順を試行した。

#### 準備
USBにubuntuを再度書き込む  
全てにcheckをつけて、ネット接続してインストール  
仮想コンソールを立ち上げる（tty1~6, セーフモード？でも良い。）  

#### nvidia / cuda関連のものをすべて削除
sudo apt-get --purge remove nvidia-*  
sudo apt-get --purge remove cuda-*  

#### おまじない１
sudo apt-get autoremove -f  
sudo apt-get autoclean -f  
sudo apt-get update && sudo apt-get upgrade -fy  

#### おまじない２
sudo apt update  
sudo apt-get -y dist-upgrade  
sudo apt-get -y autoremove  
sudo apt-get -y clean  

#### Nvidia install
sudo add-apt-repository ppa:graphics-drivers/ppa  
sudo apt-get update  
sudo apt-get install nvidia-XXX  

#### おまじない3
sudo apt install nvidia-cuda-toolkit  

#### pray
reboot

### ピットフォール
* ubuntuのインストール時に「サードパーティー製のソフトをインストール」を選ばなかった場合(ネット環境の問題など)、install後にGUIが起動しない事象。  
　[対応]
　リカバリーモードで起動し、nvidia driverをインストールする

```bash
$ sudo apt-add-repository ppa:graphics-drivers/ppa
$ sudo apt update
$ ubuntu-drivers devices
# recommendと記載されるバージョンを選ぶ(200912時点では450)
$ sudo apt install nvidia-driver-450
$ sudo reboot
# 再起動時に青い画面が出てくきたら、Enroll MOK → Yes → reboot
$ nvidia-smi
# 表示されたら成功
```
