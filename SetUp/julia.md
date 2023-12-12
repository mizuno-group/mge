# Juliaの環境構築
juliaをjupyter labで使えるようにする.  
ただし, ちょくちょくアップデートがあるので要注意. あくまで2020年1月13日版.  
特に2018年8月にメジャーアップデートがあったので, それより前の記事には気を付ける.  

***
## 1. 本体のインストール
julia本体をインストールする.  
### 1-1. DL  
[公式](https://julialang.org/downloads/)よりダウンロードする.  
### 1-2. インストール  
指示に従って進めるだけ, すぐ終わる.  
* インストール先は~AppData/Localがデフォになっているので, 適当にユーザー直下とかの方がわかりやすいかもしれない.  

### 1-3. pathの設定  
`[インストール先のpath]/bin`をユーザー環境変数の`path`に追加する.  
### 1-4. 再起動  
再起動しないとだいたいこの手のものは使えない.  
### 1-5. 確認  
anaconda promptでjupyter labの仮想環境をactivateした後, `julia`と打ち込むと可愛いjuliaの画面が出るはず.  

***
## 2.  IJuliaの導入
IJuliaは, juliaを扱うためのブラウザベースの開発環境？  
notebookの拡張らしい.  
[参照](https://qiita.com/hassaku/items/1ff498b43aa58fe2b8b4)  
### 2-1. ビルド
IJuliaのソースをDLしてきてビルドする.  
1-5.の後に(i.e. juliaの画面上で), 

    using Pkg
    Pkg.add("IJulia")

少々時間がかかるが放置していれば終わる.  
### 2-2. 確認1
anaconda promptを起動してjupyterlabの仮想環境に入る.  
`jupyter kernelspec list`を打ち込み, JupyterLabにJuliaのカーネルが追加されたかを確認する.  
### 2-3. 確認2
いつもどおりjupyter labを起動し, new launcherにJuliaのカーネルが追加されたかを確認する.  
### 2-4. 確認3  
new launcherを起動し, 世界にこんにちはして最終確認.  
`print("hello, world")`  

## 3.  とりあえず入れておくパッケージ
どれがいいかわからないので[適当なHP](https://nbviewer.jupyter.org/github/takuizum/julia/blob/master/jmd/summaryPkg.html)を参照して導入しておく.  
全て入れなくともいくらか入れれば自動的にrequirmentの関係で入ってくるはず.  

入れ方は, `using Pkg;Pkg.add("XXXX")`
* Gadfly: ggplot2っぽい描画  
* StatsPlots: 統計分析用描画  
* Statistics: 記述統計用  
* SpecialFunctions: ベータ分布やら, ベイズの時に使うのかも  
* Random: 乱数発生  
* ForwardDiff: 微分  
* Turing: モデリング用？  
* (LinearAlgebra: 線形代数. Statisticsのrequirement)  
* (Distributions: 確率分布色々. Gadflyのrequirement)  
* (StatsFuns: ロジスティック関数, ソフトマックス関数やら. Gadflyのrequirement)  
* (StatsBase: ヒストグラム描くときに使えるらしい. Gadflyのrequirement)  

***
# その他
## パッケージ管理  
パッケージは, `C:\Users\[ユーザー名]\.julia\packages`に格納される.  
以下, よく使いそうなコマンド:  
* パッケージのインストール: `using Pkg;Pkg.add("XXXX")`  
* パッケージのアンインストール: `using Pkg; Pkg.rm("XXXX")`
* パッケージの確認: `using Pkg;Pkg.installed()`  
* パッケージのアップデート: `using Pkg;Pkg.update()`  
* ↑はパッケージを全てアップデートしてしまう. pinで特定のパッケージのバージョンを固定できる模様.  

## 参考文献
[インストール周り](https://ysss.hateblo.jp/entry/2018/09/03/221941#Julia%E3%81%ABIJulia%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%81%99%E3%82%8B)  
[インストール周り2](https://ysss.hateblo.jp/entry/2018/08/19/003207)  
[パッケージ管理](https://myenigma.hatenablog.com/entry/2019/02/21/224849)  
[使い方](https://ysss.hateblo.jp/entry/20180925/1537883323)  
