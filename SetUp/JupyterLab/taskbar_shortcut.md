# JupyterLabのショートカットをタスクバーに作成する方法

JupterLabを起動するためにいちいちAnacondaPromptを経由するのは少し億劫なので、Windows 10のタスクバーからJupyterLabを起動する方法をここに記載する。

## バッチファイルを作成する

バッチファイルはコマンドプロンプトの処理をあらかじめ記述し、ワンクリックで自動で実行させるためのファイルである。以下が今回使うバッチファイルのソースコード。

```
call %ANACONDADIR%\Anaconda3\Scripts\activate.bat
call %ANACONDADIR%\Anaconda3\condabin\conda activate %ANACONDAENVIRONMENT%
cd /d %RESEARCHDIR%
jupyter lab
```

ここで、%ANACONDADIR%にはAnacondaがinstallされているディレクトリをいれよう。
%RESEARCHDIR%には自分が普段研究で使用しているディレクトリ（dryとか）をいれよう。%ANACONDAENVIRONMENT%の部分には自分が普段使用している環境名をいれる。

このテキストをJupyterLab.batというファイル名で適当な場所に保存する。このrepositoryからダウンロードしたものを改変してもよい。

## ショートカットをタスクバーに貼り付ける

前述の保存したJupyterLab.batファイルを使い、以下のサイトに従ってタスクバーに貼り付ける。

https://toolmania.info/post-10234/

すると、タスクバーからワンクリックでJupyterLabを環境指定までやったうえで起動できる。

## デフォルトのブラウザがEdgeなどになってしまっている場合

Anaconda Promptを起動。以下のコマンドを入力。

```
jupyter lab --generate-config
```

C:\Users\アカウント名\.jupyterの直下にjupyter_notebook_config.pyというファイルが作成されるので、そのファイル中の

```
# c.NotebookApp.browser = ''
```

という行を探し出し、

```
c.NotebookApp.browser = '"C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe" %s'
```

に変更すると、chromeで起動できるようになる。
