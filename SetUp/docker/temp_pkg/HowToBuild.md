# docker-composeのパッケージ作成
docker-composeを使ってapplication containerを個別に立ててパイプラインを作る時用のメモ  
NGSなどプラットフォームがばらつく場合に使う  

# pros/cons
- pros  
  - アプリごとにDockerfileとrunnerを書けばよいので既存の使い回しやら便利  
  - 一つのDockerfileに書こうとするとconflictするケースなどでも簡単に書ける  
- cons  
  - main.shはホストマシンに影響するのでホスト環境を壊せる  
  - その点で仮想環境の隔離性が失われている  

# 構成
- temp_pkg  
  - ユーザー自身で変更するファイル  
    - config.txt (解析条件指定用, 解析ごとに変更)  
    - .env (bindのsourceを指定, 自身の環境構築時のみ変更)  
  - ユーザーは基本触らないファイル  
    - docker-compose.yml (docker-composeファイル)  
    - main.sh (解析実行用)  
      - main2.sh (compose v2用のmain.sh, コマンドを```docker compose```に置換している)  
    - app1 (app1コンテナ用)  
      - main.sh (app1実行用)  
    - app2 (app2コンテナ用)  
      - main.sh (app2実行用)  
    - app3 (app3コンテナ用)  
      - main.sh (app3実行用)  

# 構築フロー
- アプリごとにDockerfileを書き, runner (シェルスクリプト, .py, .Rなど)を用意する  
  - 基本runnerはシェルスクリプトにして, サブモジュールとして.pyや.Rを用意する方がベターか  
- docker-compose.ymlに反映  
- .envを準備  
- config.txtを準備  
- テスト用データとconfig.txtを用意してテスト  

## 構築の際, 念頭に置いておくべき事項
- 解析実行用のmain.shはホストのパスがメインだが, ```docker-compose exec appX YYYY```とdocker-composeを実行する際にはcontainerのパス  
  - そのため適宜ホストのパスをcontainerのものに変換する必要がある  
- 全てのシェルスクリプトにて, 入力されたパスは最初にabsoluteに変換しておく  
- 入力データは一つにまとめ, 入力の際にはそのフォルダのパスを指定する形にする  
- 出力は入力フォルダと同じ階層にresultとして出力する  
- appごとにエラーチェックして途中で止まるようにする  


***
# 使い方
## 1. 環境構築
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
  - 変更にはvimなどを使うか事前にvscodeなどで変更してから渡す  
  - docker-compose.yml内のbindのsourceを外部から与える形  
  - .envはそのままだと見えないので注意, ```ls -a```などして確認  
4. ```docker-compose build```  
  - rnaseq_pkg内 (docker-compose.ymlがある場所) で実行する  
  - docker-composeがインストールされていないければ適宜インストールする  
  - 必要なimageが全て作成される  
  - compose v2の場合```docker compose build```  


## 2. 解析
1. 解析対象のfastq.gzを一つのフォルダにまとめる  
2. config.txtを書き換える  
  - 方法は何でも良い, vimがベタだろうがtextにしているのでローカルでも変えやすい  
  - 入力必須  
    - INPUT_DIR (解析対象のfastqが存在するフォルダのパス)  
    - SPECIES (解析対象の種, human, mouse, ratのいずれかのみ対応)  
  - オプション  
    - SALMON_IDX_PATH (salmonインデックスを既に作成済みの場合指定する, 速くなる)  
    - TX_GTF_PATH (GTFファイルを既に入手済みの場合指定する, 速くなる)  
    - EXTENSION (fastqファイルの拡張子が異なる場合指定する, fq.gzも結構ある)  
    - OUTPUT_EXP (最終的なgene expressionのファイル名, 拡張子なし)  
    - OUTPUT_TX (上記のtranscript版)  
3. ```docker-compose up -d```でコンテナを立ち上げる  
  - compose v2の場合```docker compose up -d```  
4. rnaseq_pkg内で```./main.sh```を実行する  
  - 初めての実行時にはmain.shに実行権限を与えておく  
    - ```chmod 777 main.sh```  
  - compose v2で```docker compose```コマンドを使用している場合は```main2.sh```を使用する  
  - compose v2から```docker-compose```ではなく```docker compose```を使う方針に替わりつつある  
5. ```docker-compose down```でコンテナを終了する  
  - compose v2の場合```docker compose down```  
6. 解析対象フォルダと同じdirectoryにresultフォルダができる, このうちres_summaryをscpなどで回収して終了  
  - resultには全ての計算結果が入っているので, 回収時には要注意. 普通ならres_summaryだけで十分なはず  
  - scpの転送はサーバーからクライアントへの転送は転送対象の位置が逆になるだけ  
  - 例```scp -i [秘密鍵のパス] -P [ポート番号] [サーバー名]@[IP]:[サーバー内のres_summaryのパス] [クライアント内の保存したい先のパス]```  