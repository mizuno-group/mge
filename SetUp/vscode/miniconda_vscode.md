# miniconda - vscodeでpython環境を作る@win
minicondaをインストールした後にvscodeを入れるとGUIベースで環境構築できる.  
minicondaの部分はanacondaでももちろんOKだが, ノートPCのときとか軽い方がいいときのため.  
windows, 2021/3/21, 水野  

***
# miniconda
## 0. 参考
[参考1](https://dorapon2000.hatenablog.com/entry/2020/04/29/152251)  
[参考2](https://qiita.com/yubessy/items/2dd43551aa8308dc7eca)  

## 1. install
minicondaをぐぐって公式サイトからインストーラーをDLする.  
基本的にデフォルト設定のまま進めれば問題ない.  
path設定もやってくれるから楽.  

## 2. 環境構築
仮想環境を作っておく.  
anaconda promptを起動して以下を入力.  

### 仮想環境構築

```
# 仮想環境構築
# test_envの箇所はなんでもいい, 名前
conda create -n test_env  

# 仮想環境activate
conda activate test_env

```

prompt画面のユーザー (左端) がbaseからtest_envになったら切り替わっている.  
この状態でパッケージのインストールなりを行う.  

### 仮想環境の扱い
簡単な使い方  

```
# 仮想環境を切り替える
conda deactivate  

# 仮想環境を削除する
conda remove -n test_env  

# 仮想環境の一覧を確認する
conda info -e  

```

## 3. パッケージのインストール
パッケージマネージャーとしてcondaとpipを混ぜると良くないようなので, 分けて用意するといい.  
印象としては, 　
- conda  
    - パッケージの質がいい  
    - 数が少ない  
    - 複雑で互換性にうるさい  
- pip  
    - パッケージの種類が豊富  
    - 最近多い印象  
    - シンプルで互換性がゆるい  
    - その分見えない部分でエラーが起きている可能性があるが気づけない怖さがある  

なんだかんだで最近水野はpipが多いです.  

### condaの場合

```
# まず入れたい環境をactivate
conda activate condaenv  

# jupyterは必須
conda install jupyter

# xxxxパッケージをinstallしたい場合
conda install xxxx  

```

### pipの場合

```
# まず入れたい環境をactivate
conda activate pipenv  

# jupyterは必須
conda install jupyter

# 最初にpipをインストールする
conda install pip

# 以降はいつものpip
pip install xxxx  

```

## 4. パッケージの管理
minicondaの場合は更地なのでゼロベースでパッケージを準備する必要がある.  
全て片っ端から入れていくと面倒なので, 使いまわしそうなベースの環境はyamlに吐き出させておくと再利用できて便利.  
他の人に共有すれば共有したyamlベースで環境を作成できる.  
もちろんyaml自体を自分で書き換えたり作成しても同じように読み込んで構築できて便利.  
本リポジトリにcondaにpip環境を作る際の最小パッケージを出力したyamlを置いておくので必要があれば使いましょう.  

```
# 保存したい環境をactivate
conda activate pipenv  

# 環境をyamlで保存する
# 名前はなんでもいい
# anaconda promptのcurrent directory (デフォではユーザー直下) に保存される
conda env export > pipenv.yaml  

# 保存したyamlから環境構築したいとき
conda env create -n --file test_env.yaml  

```

### 入れておいた方が良さそうなパッケージ一覧
できる限り依存関係が多いパッケージから入れていった方が楽.  
とりあえずpip版のみ, condaの場合は```-c```でチャンネル指定して```conda-forge```だとか特定のチャンネルから呼び出す必要があるものもあるから注意  

```
conda install pip
pip install pandas scikit-learn matplotlib seaborn pathlib tqdm

```

こういうのを書いていくのが面倒なので.yamlを活用しましょう.  


***
# vscode
## 1. install
vscodeでぐぐって出てくるサイトからインストーラーをDLする  
基本的にはuser権限のみのuser版を使う (cf. system)  
手順に従ってインストールする  
やばい選択肢はないので基本弄らずそのままでOK (pathを自分で弄りたい場合には「PATHへの追加」のチェックを外す)  
インストール後, path設定の変更を反映するために再起動する  

## 2. vscodeでpython環境の構築
vscodeにextension (拡張機能) を入れてカスタマイズしていく感じ.  
python, jupyterを入れれば一通りpythonでやりたいことができる.  
View > extensionsと進むとextensionが表示されるので, GUIベースでクリックしてインストールするだけ.  
Lintによるコードの自動整形が売りの一つでもあるので, coding規約関連をanaconda promptでインストールしておく.  

```
conda activate pipenv
pip install flake8 autopep8

```

## 3. anaconda promptの呼び出し
上記ではanconda promptを通常どおり呼び出して実行することを念頭に置いているが, vscode.settingファイルを弄ればvscodeのターミナル上からも実行できる.  
### 設定方法
- ユーザー環境変数の設定に移動  
- Pathを選択  
- 以下の二つを新規に設定  
    - ```C:\Users\[ユーザー名]\miniconda3```  
        - python.exeがあるところ. デフォだとだいたいこの位置  
    - ```C:\Users\[ユーザー名]\miniconda3\Scripts```  
        - 上記のScriptsディレクトリ. activateとかのbatファイルがある位置  
- PC再起動  

### 使用方法
以上をやることで以下のようにanaconda propmtをvscode上で起動できる  
- ```shift + ctrl + \` ```でターミナル呼び出し  
- いつもどおり```conda xxx```  

### TIPS
- デフォルトだとcmdではなくpowershellが呼び出す？  
- interpreterを選んでいる場合, 当該interpreterの環境がデフォでrunされる  

[参考1](https://blog.beachside.dev/entry/2017/12/25/000000)  
[参考2](https://www.javadrive.jp/vscode/terminal/index2.html#:~:text=%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%83%91%E3%83%AC%E3%83%83%E3%83%88%E3%81%8B%E3%82%89%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B%E3%82%B7%E3%82%A7%E3%83%AB%E3%82%92%E5%A4%89%E6%9B%B4%E3%81%99%E3%82%8B,-%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B%E3%82%B7%E3%82%A7%E3%83%AB&text=%E3%80%8C%E8%A1%A8%E7%A4%BA%E3%80%8D%E3%83%A1%E3%83%8B%E3%83%A5%E3%83%BC%E3%81%AE%E4%B8%AD%E3%81%AE,%E3%82%92%E3%82%AF%E3%83%AA%E3%83%83%E3%82%AF%E3%81%97%E3%81%A6%E3%81%8F%E3%81%A0%E3%81%95%E3%81%84%E3%80%82)  
[参考3](https://qiita.com/_meki/items/5b4f06318f1a0986c55c)  


## 4. vscodeの削除
削除したいときはCode, extensionsフォルダに注意, 単にアプリと機能から削除するだけではキャッシュが残る.  
### 方法
- 本体を「アプリと機能」から普通に削除.  
- ```C:\Users\[ユーザー名]\AppData\Roaming```にあるCodeフォルダを削除.  
- ```C:\Users\[ユーザー名]```にある.vscodeフォルダを削除.  
[参考](https://www.atmarkit.co.jp/ait/articles/1810/12/news026.html)  

***
# 使い方
基本的に```shift + ctrl + p```からスタートする.  
上記ショートカットで様々な機能への検索画面が出る.  

## 1. 使用するフォルダを選ぶ
File -> Open Folder  

## 2. python環境の選択
```shift + ctrl + p```  
```Python: Select Interpreter```  
出てくる環境から使いたいものを選ぶ.  

## 3. ipynbの作成
```shift + ctrl + p```  
```Jupyter: Create New Blank Notebook```  
これでuntitled.ipynbが該当フォルダ内に作成される.  

## 4. ファイル検索
```shift + ctrl + f```  
or  
```shift + ctrl + j```  
で開いたフォルダ以下のファイル検索ができる.  
jが詳細版.  
検索するときはResearchフォルダをオープンしてからやると全体を検索できる.  