# How to use grein
## URL
[GREIN](http://www.ilincs.org/apps/grein/?gse=)

`http://www.ilincs.org/apps/grein/?gse=`

## 使い方
### Data Check
Search for GEO series (GSE) accession にほしいRNAseqの番号を入力。この時以下の3パターンに分かれる

1. This dataset has already been processed. Please see the following table.と表示されたら既に加工済みのfileである。
1. まだ加工されていません→加工の段階に自動的に入る。Processing Consoleで進捗を確認できる。
1. このDatasetはgrain上にないかRNAseqじゃねえ！って言われたらあきらめて他の方法を探す(新しめのfileだとあるっぽい？)

### Download
加工済みか、加工が終わったら以下の手順でダウンロードできる
1. 下のGEO acessionの番号　をクリック
1. Count Table　をクリック
1. Show Count Table　をクリック
1. Download Data　をクリック

## 所感
- MappingしているのでRaw dataの加工は2,3日単位でかかると思っておく。
- processingは順番なので気長に待つ。あまり多くのファイルを一気に投げるのは避けたほうがいいだろう。
- 内部データの性状など、グラフ表示してあるので気軽に確認できる。
