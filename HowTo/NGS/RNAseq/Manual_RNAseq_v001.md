# RNA-seqのマニュアル
以下のフローで実施するRNA-seqのfastq -> expressionのマニュアル.  
docker-composeを使い, CUIベースで実施.  

## history & version
ver0.0.1  
- 211228  
  - 作成開始  

## フロー
- QC: PRINSEQ++  
  - python, conda  
- mapping/定量: salmon  
  - python, conda  
- 整形: tximport  
  - R  

***
# ■ 簡易版
# 0. 環境構築
1. docker-compose.ymlのsourceの部分を, 使用している計算機サーバー内でコンテナと共有したい領域のパスに変更する  
  - 起動ディスクではなく保管ディスクがいいので例えば以下のようになる  
    - ex) ```source: /mnt/data1/rnaseq```  
2. ```docker-compose build```  
  - rnaseq_pkg内 (docker-compose.ymlがある場所) で実行する  
  - docker-composeがインストールされていないければ適宜インストールする  
  - 必要なimageが全て作成される  

***
# 1. PRINSEQ++
1. ```docker-compose up -d```  
  - これでコンテナが立ち上がる, 以降続けてやる場合は不要  
2. ```docker-compose exec prinseq /main.sh {fastq.gzを格納したディレクトリのパス}```  
  - 拡張子がfastq.gzでない場合は, ```-e```オプションで指定する  
    - ex) ```docker-compose exec prinseq /main.sh -e fq.gz 211130_Shiseido```  
  - res_prinseqディレクトリに以降使用するgood_outが格納される  

***
# 2. salmon
index作成とmapping/定量の2パートに分かれる.  

## index作成
作成済みの場合は飛ばす, 時間がかかるので注意  
1. ```docker-compose exec salmon /prep_index.sh -h```  
  - ```-h```, ```-m```, ```-r```でそれぞれhuman, mouse, ratを指定  
  - 同時に並べることも可  
  - ex) ```docker-compose exec salmon /prep_index.sh -h```  

## mapping/定量
1. ```docker-compose exec salmon /main.sh {QC後のfastqを格納したディレクトリのパス} {作成したsalmon indexのパス}```  
  - 出力されるディレクトリ内のquant.sfが発現量行列  

***
# 3. tximport
1. ```docker-compose exec tximport /main.R -h```  
  - ```-h```, ```-m```, ```-r```でそれぞれhuman, mouse, ratを指定  
  - transcript level, gene levelそれぞれのresultファイルが個別に出力される  
2. ```docker-compose exec salmon /integrate.py```  
  - pythonの入っているsalmon環境にて, python上でデータの整形・出力, 最終産物exp_gene.txtが得られる  

***
# ■ 詳細版
# 0. 環境構築
1. docker-compose.ymlのsourceの部分を, 使用している計算機サーバー内でコンテナと共有したい領域のパスに変更する  
  - 起動ディスクではなく保管ディスクがいいので例えば以下のようになる  
    - ex) ```source: /mnt/data1/rnaseq```  
2. ```docker-compose build```  
  - rnaseq_pkg内 (docker-compose.ymlがある場所) で実行する  
  - docker-composeがインストールされていないければ適宜インストールする  
  - ```docker-compose build```で必要なimageが全て作成される  
  - ```docker-compose up -d```でコンテナ作成  
  - ```docker-compose down```でコンテナ終了  
  - tximportで使用するGenomicFeaturesが異様に重い…  

***
# 1. PRINSEQ++
1. ```docker-compose up -d```  
  - これでコンテナが立ち上がる, 以降続けてやる場合は不要  
  - ```-d```オプションはバックグラウンドでコンテナを立てるためのもの  
2. ```docker-compose exec prinseq /main.sh {fastq.gzを格納したディレクトリのパス}```  
  - 拡張子がfastq.gzでない場合は, ```-e```オプションで指定する  
    - ex) ```docker-compose exec prinseq /main.sh -e fq.gz {fastq.gzを格納したディレクトリのパス}```  
  - res_prinseqディレクトリに以降使用するgood_outが格納される  
  - ```-t```オプションで使用するthreads数を決定できるが, 分割により配列に差が出るとのことなので基本は触らない (```-t 1```と同じ)  
  - threads=1としているためか存外遅い    

***
# 2. salmon
index作成とmapping/定量の2パートに分かれる.  

## index作成
作成済みの場合は飛ばす, 時間がかかるので注意  
1. ```docker-compose exec salmon /prep_index.sh -h```  
  - ```-h```, ```-m```, ```-r```でそれぞれhuman, mouse, ratを指定  
  - 同時に並べることも可  
  - ex) ```docker-compose exec salmon /prep_index.sh -h```  
  - threadsは12くらいがちょうどよいらしいので特段いじっていない, おそらく染色体数とかに起因するオーバーヘッドの問題でスケーラブルではないのかと  
  - selective alignmentを採用している. 以前のsalmonにはなかったもので, genome由来の配列をdecoyにして補正をかけている  
  - 適宜時代によって参照する遺伝子のバージョンが変わりうるので注意. Dockerfileにべた書きしている  

## mapping/定量
1. ```docker-compose exec salmon /main.sh {QC後のfastqを格納したディレクトリのパス} {作成したsalmon indexのパス}```  
  - 出力されるディレクトリ内のquant.sfが発現量行列  

***
# 3. tximport
1. ```docker-compose exec tximport /main.R {種の選択} {GTFファイルの場所}```  
  - ```-h```, ```-m```, ```-r```でそれぞれhuman, mouse, ratを指定 (第一引数)  
  - GTFファイルはhuman, mouseはgencode, ratはensemblより入手している  
  - GTFファイルがない場合DLするため時間がかかるので注意, といっても数十M程度  
  - salmonのindex作成時と同じく, 適宜時代によってバージョンが変わりうるので注意. Dockerfileにべた書きしている  
  - Rでのデータ操作があまりにバカバカしかったので, 個別に出力している  
  - transcript level, gene levelそれぞれのresultファイルが個別に出力される
  - Rscritpで指定しないとerrorが出た。（220216 morita）
2. ```docker-compose exec salmon /integrate.py```  
  - あまりにRのデータ整形周りが酷いのでpythonで…  
  - pythonの入っているsalmon環境にて, python上でデータの整形・出力  
  - txについても同じことが可能なはずだが, おそらくindexがいくらか被っているのでシンプルにやるとエラーが出る  
  - ```docker-compose exec salmon /integrate.py -i {入力フォルダ} -o {出力ファイル名 (拡張子無し)} -s {入力のsep} -e {入力の拡張子}```  
  - exec salmon python /.pyで指定した。（220216 morita）