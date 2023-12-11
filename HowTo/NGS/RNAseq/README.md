# RNA-seqのマニュアル
以下のフローで実施するRNA-seqのfastq -> expressionのマニュアル.  
docker-composeを使ってアプリケーションコンテナを作成, CUIベースで実施.  
解析条件はconfig.txtで与える, 一度環境構築した後弄るのはこのファイルのみ.  

# ToDo
テスト  
現状DLたくさんしてるとNCBIなどに目をつけられる？  
gencodeのファイルがDLできなくなることがある  

## フロー
- QC: PRINSEQ++  
  - python, conda  
- mapping/定量: salmon  
  - python, conda  
- 整形: tximport  
  - R  

## 構成
- rnaseq_pkg  
  - 自身で変更するファイル  
    - config.txt (解析条件指定用, 解析ごとに変更)  
    - .env (bindのsourceを指定, 自身の環境構築時のみ変更)  
  - 基本触らないファイル  
    - docker-compose.yml (docker-composeファイル)  
    - main.sh (解析実行用)  
      - main2.sh (compose v2用のmain.sh, コマンドを```docker compose```に置換している)  
    - prinseq (prinseqコンテナ用)  
    - salmon (salmonコンテナ用)  
    - tximport (tximportコンテナ用)  

## 呼称
- クライアント  
  - クライアントPC, 自分の手元のPC, ローカル  
- サーバー  
  - サーバーPC, 計算機サーバーだとかsshでアクセスする先のPC  

***
# 1. 環境構築
1. サーバー側に導入されていなければdocker-composeのインストール  
  - 適宜ぐぐってインストール ([この辺り](https://zenn.dev/shimakaze_soft/articles/02aebaedeb43b6)とか)  
  - ただし結構バージョン間差が激しいので注意, 不明な時はわかりそうな人に聞く  
2. rnaseq_pkgをサーバー側に導入  
  - サーバーのメインユーザーの下に自分の名前のdirを作成し, そこにもってくると良い  
  - 例```/home/micgm1/mizuno/rnaseq_pkg```  
  - 移動はgitがあればcloneしてくれば速い  
    - ```git clone https://github.com/mizuno-group00/environment.git```  
  - あるいはクライアントPC内の```C:\Users\[ユーザー名]\github\environment\NGS\RNAseq\rnaseq_pkg```をscpで転送するのもコンパクトでおすすめ  
    - 例```scp -i [秘密鍵のパス] -P [ポート番号] [rnaseq_pkgのパス] [サーバー名]@[IP]:[サーバー内へのコピー先]```  
3. docker-compose.ymlと同じ階層内の.envファイル内の```BSRC=XXXX```のXXXXを変更し, 使用している計算機サーバー内でコンテナと共有したい領域のパスに変更する  
  - 起動ディスクではなく保管ディスクがいいので例えば以下のようになる  
    - ex) ```BSRC=/mnt/data1```  
    - BSRC: bind sourceの略  
  - 変更にはvimなどを使うか事前にvscodeなどで変更してから渡す  
  - docker-compose.yml内のbindのsourceを外部から与える形  
  - .envはそのままだと見えないので注意, ```ls -a```などして確認  
4. ```docker-compose build```  
  - rnaseq_pkg内 (docker-compose.ymlがある場所) で実行する  
  - docker-composeがインストールされていないければ適宜インストールする  
  - 必要なimageが全て作成される  
  - compose v2の場合```docker compose build```  


# 2. 使用方法
1. 解析対象のfastq.gzを一つのフォルダにまとめる  
2. config.txtを書き換える  
  - 方法は何でも良い, vimがベタだろうがtextにしているのでローカルでも変えやすい  
  - 入力必須  
    - INPUT_DIR (解析対象のfastqが存在するフォルダのパス)  
    - SPECIES (解析対象の種, human, mouse, ratのいずれかのみ対応)  
    - SEQ_END (sequenceのsingle/pair-endの指定, singleかpairを選択)  
    - RES_ONLY (ストレージ容量が小さい時など解析の途中結果を出力しない場合, trueかfalse)
  - オプション  
    - SALMON_IDX_PATH (salmonインデックスを既に作成済みの場合指定する, 速くなる)  
    - TX_GTF_PATH (GTFファイルを既に入手済みの場合指定する, 速くなる)  
    - EXTENSION (fastqファイルの拡張子が異なる場合指定する, fq.gzも結構ある)  
  - 残るオプションはAppendixへ  
3. ```docker-compose up -d```でコンテナを立ち上げる  
  - compose v2の場合```docker compose up -d```  
4. rnaseq_pkg内で```./main.sh```を実行する  
  - 初めての実行時にはmain.shに実行権限を与えておく  
    - ```chmod 755 main.sh```  
  - compose v2で```docker compose```コマンドを使用している場合は```main2.sh```を使用する  
  - compose v2から```docker-compose```ではなく```docker compose```を使う方針に替わりつつある  
5. ```docker-compose down```でコンテナを終了する  
  - compose v2の場合```docker compose down```  
6. 解析対象フォルダと同じdirectoryにresultフォルダができる, このうちres_summaryをscpなどで回収して終了  
  - resultには全ての計算結果が入っているので, 回収時には要注意. 普通ならres_summaryだけで十分なはず  
  - scpの転送はサーバーからクライアントへの転送は転送対象の位置が逆になるだけ  
  - 例```scp -i [秘密鍵のパス] -P [ポート番号] [サーバー名]@[IP]:[サーバー内のres_summaryのパス] [クライアント内の保存したい先のパス]```  

***
# Appendix
## config.txtの普段変更しないオプション
- OUTPUT_EXP (最終的なgene expressionのファイル名, 拡張子なし)  
- OUTPUT_TX (上記のtranscript版)  
- xxx_Tx (salmon index準備用のtranscriptsのURL, クォーテーションなし)  
- xxx_Gen (salmon index準備用のgenomeのURL, クォーテーションなし)  
- xxx_GTF (tximport用のGTFファイルのURL, クォーテーションあり)  
  - Tx, Genはシェルスクリプト, GTFはRのためDL用URLをクォーテーションで囲むか否かが異なるので要注意  

## scpの使い方
- ssh接続確立後はscpによるファイル転送が便利  
- windows powershell辺りを立てて, 以下を実行  
- pseudo: ```scp -i [秘密鍵のパス] -P [ポート番号] [ローカルのrnaseq_pkgのパス] [サーバー名]@[IP]:[サーバー内へのコピー先]```  
- 具体例: ```scp -i C:\Users\XXX\.ssh\id_rsa_YYY -P 49ZZZ C:\Users\XXX\github\...\rnaseq_pkg YYY@133.11.xx.xxx:/home/YYY/mizuno```  

***
# history
- 220802 v1.0.1  
  - single/pair endの設定を反映  
  - line 49の軽微なバグフィックス  
  - ハードコーディングしていたURLをconfig.txtに移動  
  - res_only modeの導入  