# ■ salmon環境の構築  
hash化しておいた配列を使ったk-mer mapping (quasi-mapping) による高速なリードカウント法として, salmonとkallistoが現状ツートップ (2020/5/20).  
こだわりはないがsalmonを使ってみる.  

***
# ■ インストール
* linux環境が必要. CentOS7を使った場合を示す. anaconda環境構築までの詳細はtipsリポジトリ参照.  
* なんてことはなく[公式](https://combine-lab.github.io/salmon/getting_started/)の指示通り進めればOK.  
* anacondaでsalmon専用環境を作って実施する.  
    
    ```
    conda config --add channels conda-forge
    conda config --add channels bioconda
    conda create -n salmon salmon
    ```
    
* 一応PCを再起動しておく.  

***
# ■ 起動
普通に端末から  
`conda activate salmon`  
* ただし初回はそのまま起動しようとすると怒られる.  
`CommandNotFoundError: Your shell has not been properly configured to use 'conda activate'.`
* 以下の初期化が必要な模様  
`conda init bash`  
* その後に一度exitして端末を再起動しておく.  

***
# ■ 使い方
[ここ](https://qiita.com/TyaoiB/items/ba30a0e85218325813fe)がわかりやすそう.  

## 1. transcript情報の入手  
* EnsembleとGencodeだと後者の方が多いようなので後者を使う.  
* 一般ユーザーでログインしているとcurrent directoryは/home/ユーザーとなっている.  
* `cd xxxx`で下層のxxxxディレクトリへ移動する.  
* `mkdir xxxx`でxxxxディレクトリを作成する.  
* `pwd`でcurrent directoryを表示する.  
* `cd -`でcurrent directoryの親ディレクトリへ移動する.  
* example)  
    
    ```
    mkdir Transcript # 適当に作成する
    cd Transcript
    mkdir Mouse
    cd Mouse
    wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M20/gencode.vM20.transcripts.fa.gz
    ```
    
* wget以下を適宜変えればhumanを入手可能.  
ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.transcripts.fa.gz  
* ただしratはなさげか？その場合は同じ要領でEnsembleから落とせる.  
    
    ```
    wget ftp://ftp.ensembl.org/pub/release-95/fasta/mus_musculus/cdna/
    ```

## 2. salmon indexの作成  
`salmon index -t [fastaファイルのパス] -i [index名] -k [k merの指定]`  
* 高速化を達成するためのhash作成.  
* fastaは.gzのままでOK.   
* kはデフォルトで31となっている, あまり変更する必要はない模様.  
* example)  
    
    ```
    cd /Volumes/Samsung500_J/human_salmon
    time salmon index -t Homo_sapiens.GRCh38.cdna.all.fa.gz -i Homo_sapiens.GRCh38_salmon_index -k 31
    ```

## 3. mapping  
    
    salmon quant -i [2.で作成したindex名] \
    -l [library type] \
    -1 reads1.fq \
    -2 reads2.fq \
    --validateMappings \
    -o [output file path]
    
* 色々指定が多い.  
* -l: ライブラリータイプの指定, strandedかunstrandedかくらい？わかりづらいけどLの小文字.  
* -1: pair-endの場合のleft側  
* -2: pair-endの場合のright側  
* -o: output fileのパス  
* 色々ファイルが出力される. quant.sfがカウントファイルの実態な模様. こいつはDESeq2とかに投げれる.  
* example)  
    
    ```
    cd /Volumes/Samsung500_J/salmon_hoge
    salmon quant -i /Volumes/Samsung500_J/mouse_GENCODE/salmon/gencode.vM20_salmon_index \
    -l IU \
    -1 /Volumes/Samsung500_J/fastq/hoge_1.fastq \
    -2 /Volumes/Samsung500_J/fastq/hoge_2.fastq \
    --validateMappings \
    -o /Volumes/Samsung500_J/salmon_hoge/hoge_fastq_salmon_quant
    ```
    
# ■ 使い方2) シェルスクリプトでまとめてやるバージョン  
## 3. .shのファイル作成  
`vi salmon200521.sh`  
* 日付を入れておくと後で何かあったとき怖くない

## 4. .shファイルの編集  
* viに入っているので以下のように内容を編集
    
    ```
    #!/usr/bin/bash
    # salmon_indexのパス指定
    idx_path=""
    
    # current directoryの確認
    pwd
    
    sta=`date +%s`

    # file pathのリスト作成
    q1=()
    for f1 in *1.fastq; do
      q1+=($f1)
    done
    q2=()
    for f2 in *2.fastq; do
      q2+=($f2)
    done
    
    # setごとにapply
    for ix in ${!q1[@]}; do
      echo "--- set "$ix" ---"
      echo ${q1[ix]}
      echo ${q2[ix]}
      temp="salmon_quant"$ix
      salmon quant -i $idx_path -l A -1 ${q1[ix]} -2 ${q2[ix]} --validateMappings -o ${temp}      
    done
    
    # 経過時間
    end=`date +%s`
    pt=`expr ${end} - ${sta}`
    hr=`expr ${pt} / 3600`
    pt=`expr ${pt} % 3600`
    mi=`expr ${pt} / 60`
    se=`expr ${pt} % 60`
    
    echo "--- Elapsed Time ---"
    echo "${hr}:${mi}:${se}"
    echo "--------------------"
    ```
    
## 5. .shに実行権限付与  
* viを抜けてから  
`chmod 755 prinseq_loop.sh`

## 6. 実行  
`./prinseq_loop.sh`

## 7. シェルスクリプトの削除  
`rm prinseq200521.sh`

***
# ■ salmon後
salmonの出力は.sfファイルなのでそのままだと扱えない.  
Rのtximportを使ってTPMまで変換する.  
他にもwasabiだったり色々ツールはある.  
* [参考1](https://qiita.com/TyaoiB/items/ba30a0e85218325813fe)
* [参考2](https://bi.biopapyrus.jp/rnaseq/analysis/de-analysis/tximport.html)

## 1. condaでR環境に入る
`conda activate [作成したR環境名]`  
* R環境の作り方はcondaの辺り参照.  
* tximportは依存性の関係でR3.5.2でないと今は使えないっぽい？使えそうな気もするが一応一番近い3.5.3の環境を作成して利用 (200522)  

## 2. R起動/ディレクトリの確認・移動
    
    R
    getwd()
    setwd("/home/[ユーザー名]/~~~") # salmonの各データフォルダが格納されたディレクトリへ

* なぜか急にRへ入れなくなった. JupyterLab入れてから？  
* 当座の対応として, 端末の指示通りpyenv globalを指定して乗り切る(2020/5/22)  
`pyenv global anaconda3-5.3.1/envs/r_352`  

## 3. libraryの読み込み
    
    library(tximport)
    library(jsonlite)
    library(readr)
    
* ないと怒られるときは適宜インストールする`install.packages("XXXX")`  
* readrはそこそこインストールに時間がかかる.  

## 4. ファイルの読み込み
    
    key <- "salmon" # salmon出力フォルダ名を検索する共通keywordを入力
    salmon.files <- file.path(list.files(".",pattern=key),"quant.sf") # "." wdにてkeyを持つフォルダを探索してる
    names(salmon.files) <- c(list.files(".",pattern=key))
    
## 5. 転写産物発現量の取得
    
    tx.exp <- tximport(salmon.files,type="salmon",txOut=TRUE)
    head(tx.exp$counts)
    
* すぐ終わる.  

## 6. 遺伝子発現量への変換
    
    tx2gene <- data.frame(
    TXNAME = rownames(tx.exp$counts),
    GENEID = sapply(strsplit(rownames(tx.exp$counts), '\\.'), '[', 1)
    )
    head(tx2gene)
    gene.exp <- summarizeToGene(tx.exp, tx2gene, countsFromAbundance = "scaledTPM")
    head(gene.exp$counts)
    
* countsFromAbundanceは選択肢があるが, 大体の適応(DESeq2, etc)はこっちで良いようなので採用する([参考](https://www.biostars.org/p/396362/))
* TPMが得られる.  

## 7. 出力
    
    table <- as.data.frame(gene.exp$counts)
    write.csv(table,file="salmon_res.txt")
    # write.table(table,file="salmon_res.txt",col.names=T,row.names=T,sep="\t")
    # write.tableだとカラムがずれる
    
* 出力のカラムがずれるのが課題. どうやらRの仕様らしいが…

***
# ■ ToDo
* JupyterLab導入 (pathの問題かどうかも怪しい)
* symbolyc linkでHDDとの行き来を可能にする (やればできる)
* chrome導入 (EPELでも見つからない不思議)
* bashでRが呼び出せない点の改善 (pathの問題なのはよくわかった)
* Rでのベストな出力方法

***
# ■ Memo
* salmon環境のpathが通常時で通っていないので下記で指定する必要がある。
`pyenv global anaconda3-5.3.1/envs/salmon`
* これでsalmon commandが通るようになるはず (200705 morita)
