# SSHの鍵認証についての詳細
水野班でSSH接続で複数のサーバーを利用している場合の管理法についてまとめておく.  

***
# 流れ
1. 各メンバーがそれぞれのサーバーの数だけ秘密鍵・公開鍵ペアを作成する  
2. 公開鍵を各サーバーに設置する  

# 具体的な方法
[このサイト](https://qiita.com/kobake@github/items/d866392c07b03da099bf)がわかりやすい.  

## 1. 鍵のペアを用意する
1. クライアント上(Windows10想定)で行う  
2. ```mkdir c:\Users\{user name}\.ssh```で保存先を作る(既にあるならスキップ)  
3. powershellを起動する  
    * windows + xのショートカット使うと速い  
4. ```ssh-keygen -b 4096```を叩く  
    * 引き続きいくらか聞かれるので指示通りに動く  
    * -bオプションで鍵のbit数を決められる, 2048以上必須(デフォルト2048)  
5. ```Enter file in which to save the key (//.ssh/id_rsa):```と聞かれるので, ```c:/Users/{user name}/.ssh/id_rsa_XXXX```と叩く  
    * .ssh下に名前を付けて作成する  
    * ファイル名は接続するサーバーごとに変える, 略称を小文字で使用する (ex. id_rsa_hbrtr1)  
6. パスフレーズを聞かれるが現状はそのままenter(設定なし)で  

### 備考
* 誰がやるか？　→　クライアントコンピューター  
* 秘密鍵, 公開鍵をどこに置くか？　→　クライアントのuser/.ssh以下  
* linuxの場合は```ssh-keygen -f id_rsa_XXXX```で名前を変更できる  


## 2. 公開鍵の置き方
1. クライアント上でテキトウなUSBに上記作成した公開鍵(id_rsa_XXXX.pubとする)をコピー  
2. ホストのPC内に移す  
    * homeにいること前提  
    * 場所はどこでもいいが, GUIだと.sshが見えないこともあるのでコピー先はhomeが妥当か  
3. ```ls ~/.ssh```コマンドで.ssh内にauthorized_keysファイルが存在するか確認する  
    * .sshディレクトリがない場合は```mkdir ~/.ssh```で作成し, ```chmod 700 ~/.ssh```で他人に弄られないよう権限設定する  
4. authorized_keysファイルがない場合は```touch ~/.ssh/authorized_keys```で作成し, ```chmod 600 ~/.ssh/authorized_keys```で他人に弄られないよう権限設定する  
5. 以下のコマンドでauthorized_keysに自身の公開鍵を追記する  
    ```
    echo "#init_mizuno_201211" >> authorized_keys
    cat ~/id_rsa_XXXX.pub >> authorized_keys
    echo ""#end_mizuno_201211" >> authorized_keys
    ```
    * init_自分の名前_日付(6桁)とend_自分の名前_日付で公開鍵を挟む形にする  
6. 追記後, コピーした公開鍵は不要なので```rm ~/id_rsa_XXXX.pub```で削除しておく  

### 備考
* 「公開鍵を設置する」とは, ホストコンピューターの~/.ssh/authorized_keysファイルに, 公開鍵の情報を書き込むこと.  
* 5.でechoによるコメントをいれているのはどの公開鍵か判別するため. 削除する際に必要な情報  


## 3. SSHフォワーディング時の各鍵の使い分け
1. MobaXtermを起動  
2. Tunneling -> New SSH Tunnelと進む  
3. Local port fowardingを選択  
4. My computer with MobaXterm  
    * Forwarded portに8080を入力  
    * 8080: クライアント側で使用するポート, どのポートに接続したら転送されるか  
5. SSH server  
    * SSH serverにaaa.bb.ccc.dddを入力  
        * ホストコンピューターのIPアドレス  
    * SSH loginにYYYYを入力  
        * YYYY: ホストコンピューターのログインに使うアカウント名  
        * ex) hbrtr1  
    * SSH portに49152を入力  
        * 49152: SSH接続に用いるポート, ホストの設定次第なので要確認  
6. Remote server  
    * Remote serverにlocalhostを入力  
        * SSH踏み台サーバーからの接続先ホスト名/IPアドレス  
        * SSH踏み台サーバーから見たホスト名/IPアドレスなので注意  
    * Remote portに6080を入力  
        * 6080: dockerの出口にしているポート  
7. save  
8. Settingsの下の鍵マークから秘密鍵を選択  

### 備考
* どのように鍵を使い分けるのか？ → MobaXtermの場合は, tunneling時に秘密鍵ファイルを選ぶだけで良さそう.  
* MobaXtermでのフォワーディングでなく, 通常のSSH接続の場合は.ssh/configファイルを作成・編集して名前と接続を分ける方法が良さそう.  
* configを適切に設定しておけば```ssh server_name```と指定したserver名を使って簡便に認証できる模様  
* [参考1](https://www.t3.gsic.titech.ac.jp/node/333)  
* [参考2](https://did2memo.net/2017/07/23/mobaxterm-ssh-tunneling/)  
* [参考3](http://www.ellinikonblue.com/blosxom/UNIX/20150721SSH.html)  


## 4. 使用
ホストコンピューターでSSHを起動し, dockerを起動した後にMobaXtermをstartさせると, クライアントのlocalhost:8080ポートにdockerの画面が転送される  
1. ホストコンピューターでSSHを起動しておく  
    * 設定を変更したら```service sshd restart```で反映する  
    * ```service sshd start```で開始する
    * ```service sshd stop```で停止する  
    * ```service sshd status```で状態を確認する  
2. その後設定したトンネルをstart  
3. ホストコンピューターでdockerを起動  
4. クライアント上でlocalhost:8080にアクセスすると, 当該画面にdockerの画面が転送される  

## 備考
MobaXtermからSSHフォワーディングではなく普通にSSH接続する場合は[このサイト](https://qiita.com/KAWAII/items/01b87085f69998affe23)が参考になる.  
1. MobaXtermを起動し, Session > SSHと進む  
2. Remote hostにホストコンピューターのIPアドレスを入れる  
3. Specify usernameにチェックを入れ, ユーザー名を入れる (ex. hbrtr1)  
4. Portを適切なものに変える (ex. 49152)  
5. OK  



***
# 鍵認証概説
電子署名の形式の一つと思うのが正解, いくらかweb上に誤った情報があるらしいので注意.  
銀行印による押印を行員がお届け済みの印影と照らし合わせて本人確認をするようなものと思うとわかりやすい.  
秘密鍵 (ハンコ) の所有者しか正しい署名が作れないことを利用し, 署名の正しさを公開鍵 (登録されている印影) で検証してもらう形.  
[このサイト](https://qiita.com/angel_p_57/items/19eda15576b3dceb7608)がわかりやすい. 