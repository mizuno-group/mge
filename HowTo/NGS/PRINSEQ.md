# ■ 内容
2020/5/21  
PRINSEQ++のインストールと運用.  
CentOS7を想定.  

***
# ■ インストール
[ここ](https://kimbio.info/prinseqplusplus%E3%81%A7rna-seq%E3%81%AEraw%E3%83%87%E3%83%BC%E3%82%BF%E3%81%AEqc%E3%82%AF%E3%82%A9%E3%83%AA%E3%83%86%E3%82%A3%E3%82%B3%E3%83%B3%E3%83%88%E3%83%AD%E3%83%BC%E3%83%AB%E3%82%92)を参考にした.  
1. ダウンロード  
`wget https://github.com/Adrian-Cantu/PRINSEQ-plus-plus/releases/download/v1.2/prinseq-plus-plus-1.2.tar.gz`

2. 解凍, コンパイ...

    ```
    cd /home/[ユーザー名]    
    tar -xvf prinseq-plus-plus-1.2.tar.gz
    cd prinseq-plus-plus-1.2
    ./configure
    ```
    
ここでboostlibのバージョンが低いとエラーが出た　→　updateする.  

3. boostlibのupdate
    * rootに移動
    * (旧版が入ってるかもしれないので)`yum remove boost boost-devel`
    * `yum install -y gcc-c++ boost boost-devel`
    
4. 再びコンパイル, そしてインストール
    ```
    # exitしてユーザーに戻った後, 
    cd prinseq-plus-plus-1.2
    ./configure
    make
    make test
    sudo make install
    ```
    * これで上手くいった

### Ubuntuの場合
足りないpackageが違うので以下で補完
    ```
    sudo apt install build-essential
    sudo apt install boost (これ必要だったかうろ覚え)
    sudo apt install libboost-all-dev
    ```

***
# ■ 使い方
## - 入力 -
* example)
    
    ```
    # データがあるディレクトリへ移動した後, 
    prinseq++ \
    -fastq SRR8137461_1.fastq \
    -fastq2 SRR8137461_2.fastq \
    -out_name trim_SRR8137461 \
    -trim_left 5 \
    -trim_tail_right 5 \
    -trim_qual_right 30 \
    -ns_max_n 20 \
    -min_len 30 \
    -threads 24
    ```

* -fastq, -fastq2:
    * 解析対象ファイルを指定. singleの場合はfastqのみの指定. gzでもいける    
* -out_name:
    * outputファイルの名前. これに基づいて色々出てくる.  
* -threads:
    * 使用するthread数. 多くのマシンじゃこんなに使えない.  
    
## - 出力 -
* ~_good_out.fastqがフィルタを通過したデータ. なのでこれをsalmon等に投げる.  
* 解凍されるためか, ファイルサイズが4倍程度になっているので注意.  
* ~_bad_out.fastqはフィルタで落とされたデータ. 基本不要, コンタミの解析では使えそうか.  
* このデータを適宜FASTQC等でチェックしてあげるといい感じ？ただ二段階にするならFASTX-toolkitとFASTQCの組み合わせの方がいい？  

## - bashによるforループ処理 -
1. .shのファイル作成  
`vi prinseq200521.sh`  
* 日付を入れておくと後で怖くない

2. .shファイルの編集  
* viに入っているので以下のように内容を編集
    
    ```
    #!/usr/bin/bash
    # current directoryの確認
    pwd
    
    sta=`date +%s`
    echo "start :"${sta}

    # file pathのリスト作成
    q1=()
    for f1 in *1.fastq.gz; do
      q1+=($f1)
    done
    q2=()
    for f2 in *2.fastq.gz; do
      q2+=($f2)
    done
    
    # setごとにapply
    for ix in ${!q1[@]}; do
      echo "--- set "$ix" ---"
      echo ${q1[ix]}
      temp="trim"$ix
      prinseq++ -fastq ${q1[ix]} -fastq2 ${q2[ix]} -out_name ${temp} -trim_left 5 -trim_tail_right 5 -trim_qual_right 30 -ns_max_n 20 -min_len 30
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
    
3. .shに実行権限付与  
* viを抜けてから  
`chmod 755 prinseq_loop.sh`

4. 実行  
`./prinseq_loop.sh`

5. シェルスクリプトの削除  
`rm prinseq200521.sh`
