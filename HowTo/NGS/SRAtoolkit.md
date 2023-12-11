# How to Use SRA toolkit
## 参考
https://github.com/ncbi/sra-tools/wiki/01.-Downloading-SRA-Toolkit

https://kimbio.info/461854993-html

## install
### ncbiからdownload, 解凍
`wget --output-document sratoolkit.tar.gz http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-centos_linux64.tar.gz`

解凍コマンド

`tar -vxzf sratoolkit.tar.gz`
### pathを通す
一時的な奴

`export PATH=$PATH:"ここにpathを入力"/sratoolkit.2.4.0-1.mac64/bin`

一時的なのでnanoやvimなどを用いたpathの接続を書くか下記echoで追加する

永続的な奴

`echo 'export PATH="ここにpathを入力"/sratoolkit.2.4.0-1.mac64/bin:$PATH"' >> ~/.bash_profile`

一応確認しておく

`vim ~/.bash_profile`

## test run
fastq-dumpのpath確認

`which fastq-dump`

path/sratoolkit.2.4.0-1.mac64/bin/fastq-dump　と表示されたらOK

もし出なかったらpathが認識されてないのでそこを確認する。

実際にSRR390728をfastq-dumpしてみる

'fastq-dump --stdout SRR390728 | head -n 8'

いい感じの塩基配列が出力されたらOK

## Run
`fastq-dump --split-files -O [path/to/outdir] [paht/to/srafile]`

--split-files : ペアエンドの場合

-O : outdir指定のoption。そのままだと恐らくcurrent directlyに行く

例：for loop で回す場合 ($iが代入を表す)

`for i in {10..20} ; do fastq-dump --split-files -O folder/output folder/input/SRR100$i.1`
