# ChIP-Atlas概要

ChIP-Atlasは、論文などで報告された ChIP-seq データを閲覧し利活用するためのウェブサービスである。
以下にChIP-Atlasを使った転写因子まわりの解析をまとめる。

参考論文

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6280645/

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9252733/


# Befor Using ChIP-Atlas

### Install IGV
ChIP-Atlasの結果を可視化するためにIGVというソフトを利用する。
googleなどでIGVと検索または以下からダウンロード。

https://software.broadinstitute.org/software/igv/download

* Java includedにすればJava環境無しでも動作する (はず)。
* インストール無しでWeb上で結果を見ることも可能なのでその場合はこちらを省略

# Peak Browser

### Abstract
どの転写因子がどこに結合するかを調べる

### How to use

#### Web上での操作
1. IGVを起動しておく
2. ChIP-Atlas (https://ChIP-Atlas.org/) のPeak Browserを選択
3. 生物種及びリファレンスゲノムを選択
4. Experiment typeを選択
	- ChiP：ChiP-Seq
		* Histon
		* RNA polymerase
		* TFs and others：転写因子結合領域の解析
		* Input control
	- ATAC-Seq：オープンクロマチン領域の解析 (近年はこちらがDNase-Seqに比べ主流)
	- DNase-Seq：オープンクロマチン領域の解析
	- Bisulfite-Seq：メチル化領域の解析
5. Cell type Classを選択
6. Threshold for Significanceを選択 (基本は50でよい)
	* Set the threshold for statistical significance values calculated by peak-caller MACS2 (-10*Log10[MACS2 Q-value]). If 50 is set here, peaks with Q value < 1E-05 are shown on genome browser IGV. Colors shown in IGV indicate the statistical significance values as follows: blue (50), cyan (250), green (500), yellow (750), and red (> 1,000).
7. (ChiP:TFs and othersなどを選択した場合)ChiP Antigenを選択
8. 必要な場合はCell typeも選択
9. View on IGVでIGV上に結果が表示
10. 4-9を繰り返すことで転写因子の結合領域やオープンクロマチン領域をまとめて可視化できる

#### IGVでの操作
1. 上段中央に解析したい遺伝子名または遺伝子座を入力
2. まとめた結果が表示される
3. 個々の実験結果が見たい場合は右クリック → Expanded or Squished
4. さらに個々の実験をクリック → 出てきたリンクをクリック → Visualize → BigWigで波形が表示される
5. クリックしたまま左右にドラッグしたり上段右側の + や - を押すことで表示範囲の変更が可能

# Enrichment Analysis

### Abstract
ゲノム領域へのEnrichment解析