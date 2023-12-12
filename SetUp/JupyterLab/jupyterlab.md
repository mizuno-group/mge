JupyterLab tips (Maedera S, Mizuno T)
******

# 導入方法
windows用.
***
1. anaconda promptを開いて仮想環境を構築する.  
`conda create -n [environment name]`
* [environment name]には構築したい環境名を入れる.  

2. 仮想環境をactivateする.  
`conda activate [environment name]`
* 抜け出すときは`conda deactivate`で引数いらない.

3. jupyter, jupyterlab, nodejsを構築した環境へとインストール

    ```
    conda install jupyter
    conda install -c conda-forge jupyterlab
    conda install -c conda-forge nodejs
    ```

* 順番を守る.
* nodejsはlabextensionを使用するために必要.

4. extensionをインストールする.
`jupyter labextension install @lckr/jupyterlab_variableinspector`

5. sklearn, pandasをインストールする.

    ```
    conda install scikit-learn
    conda install pandas
    ```

* 作成した仮想環境中には最低限のパッケージしか入っていないので, 適宜入れる.  

6. Scriptsへのシンボリックリンクを作成する.
仮想環境中で構築するとCドライブ以下のものしか扱えないため, Dドライブのコードを読み込むことができない.  
そこでDドライブの2008MizunoTに対するシンボリックリンクをCドライブ直下に作成し, アクセスできるようにする.  
`mklink /D [シンボリックリンク名] [リンク先フォルダ]`
ex) `mklink /D C:\Users\tadahaya\2008MizunoT D:\2008MizunoT`

7. JupyterLabを起動する.
`jupyter lab`
* これでjupyterlabが立ち上がりブラウザ上で使えるようになる.
* `NotImplementedError`が出る可能性がある (191222). その場合は以下のように対処する[参照](https://stackoverflow.com/questions/58422817/jupyter-notebook-with-python-3-8-notimplementederror).    
7-1. `C:\Users\tadahaya\Anaconda3\envs\jl\Lib\site-packages\tornado\platform`にあるascyncio.pyを開く.  
7-2. 冒頭のimportの一団が終わったところに以下を追記して保存する.  

    ```
    import sys

    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    ```

******
# パッケージインストール
パッケージのインストールには極力condaを使う.  
`conda install [package name]`
存在しない場合 `anaconda search [package name]`により[package name]を提供しているchannelを探す.  
見つかれば`conda install -c [channel name] [package name]`でインストール可.  
conda-forgeがしっかりしているらしい.  
* それでも駄目な場合は, `conda install pip`の後にpipでインストールする.
## 入れておくとよいモジュール

    conda install matplotlib
    conda install seaborn
    conda install -c conda-forge pubchempy
    conda install -c conda-forge lifelines
    conda install biopython
    conda install xlrd

* biopythonに関しては, install後にbioモジュールの名前をBioに変更する必要がたまに出てくる(191225).  
C:\Users\[ユーザー名]\Anaconda3\envs\[jupyterlabの環境名]\Lib\site-packages下に存在するフォルダbioをBioに変更する(普通に名前の変更).  


******
# 出力
現状SignalsNotebook上で上手く見れる手立てがないので, Gsuiteにipynbを保存し, URLを張る.  
Export Notebook As...で出力できる.  
* Export Notebook to Excecutabl Scripts: .pyを作成.
* Export Notebook to html: .htmlを作成, 見やすくて比較的軽い.


******
# ショートカット
以下だとか適当なwebサイトを参照する. 
[参照先](https://qiita.com/YH0132/items/7588479a3c979a1f287e)
***
## コマンドモード・編集モード
セルへのコマンドモードと編集モードとがあるので留意しておく.

* 編集モード: セルにカーソルが合っている状態で`Enter`
* コマンドモード: `Esc` or `ctrl + m`

***
## ショートカット
ショートカットは概ね**コマンドモード**で使用する(以下は明示されていない限りコマンドモード).  
コマンドモードでありさえすれば後はkeyを叩くだけ.  
shiftを使わない普段のショートカットとだいたい同じ.  
* カーネル再起動: `00` (0を2回) ***超重要!! 何かしらの外部情報の変更を反映するために必須***  
* 下に新規セルを追加: `b`  
* 上に新規セルを追加: `a`  
* セルの削除: `dd`(dを2回)  
* セルのコピー: `c`  
* セルのカット: `x`  
* セルのペースト: `v`  
* undo: `z`  
* Markdownセルへの変更: `m`  
* Rawセルへの変更: `r`  
* codeセルへの変更: `y`  
* セルの実行: 編集モードにて`shift + Enter`  
* セル中の選択した部分の実行: 編集モードにてセル中の一部を選択した後`ctrl + Enter`  


******
# module開発
現状だとJupyterLabで.pyファイルを開いて変更を加えて,...というのが若干やりづらい.  
変数の逐次確認はspyderの方が上.  
module開発にはSpyderの方がよいかもしれない, その辺りは適宜個人裁量で.  
