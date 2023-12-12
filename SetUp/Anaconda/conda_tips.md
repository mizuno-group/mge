Conda tips (Mizuno T)
* pythonを扱う場合, rootに入れずanacondaで仮想環境を作ってそこに入れた方が管理がしやすい.  

******
# ■ 仮想環境構築
1. anaconda promptを開いて仮想環境を構築する.  
`conda create -n [environment name]`
* [environment name]には構築したい環境名を入れる.  

2. 仮想環境をactivateする.  
`conda activate [environment name]`
* 抜け出すときは`conda deactivate`で引数いらない.

***
# ■ packageのインストール
1. 仮想環境をactivateする.  
`conda activate [environment name]`
* 抜け出すときは`conda deactivate`で引数いらない.

2. 入れたいpackageを以下の要領で入れるだけ.  

    ```
    conda install scikit-learn
    conda install pandas
    ```

3. condaですぐに見つからない場合は, 適宜チャンネルを指定してみる. conda-forgeが良い.   

    ```
    conda install -c conda-forge pubchempy
    conda install -c conda-forge lifelines
    ```

4. アンインストールしたいとき.   

    ```
    conda uninstall pubchempy
    conda uninstall lifelines
    ```

5. アップデートしたいとき.   

    ```
    conda update pubchempy
    conda update lifelines
    ```

***
# ■ pipを使いたいとき
* condaだと見つからないパッケージも存在する.  
* そういうときはpipを使いたいが, 混ぜるとバージョンの混同やそれ以上に厄介なことが起こる (らしい).  
## 解決策
pypiのパッケージを元にcondaパッケージをビルドしてインストールするといける ([参考](https://analytics-note.xyz/mac/conda-skeleton-pypi/)).  
  
1. pypiパッケージを入れたい仮想環境をactivateする.  
`conda activate [environment name]`

1. patchがないと怒られるのでこの環境に入れたことなければインストールする.  
`conda install m2-patch`
    * windowsの場合はこれ. 他のOSだと違う (CentOSならyumでpatchとか)  

1. skeltonを使ってcondaパッケージの作成.  

    ```
    conda skeleton pypi <PACKAGE>
    conda build <PACKAGE>
    ```
    
1. ビルド  
`conda build <PACKAGE>`
    * buildの際に`conda build <PACKAGE> -c conda-forge`とすることで指定したチャンネルに属しているrequirementも拾ってくれるっぽい.  
    * 依存関係の中に特定のチャンネルのものが入っている場合も同様にチャンネル指定する必要がある`conda build <PACKAGE> -c XXXX`

1. インストール  
`conda install --use-local <PACKAGE>`  

1. お片付け
skeletonが作成したフォルダ等が残っているので削除する.  
`conda build purge`  

1. アンインストール  
condaのパッケージとして入っているので普通に`conda uninstall XXXX`でアンインストールできる.  

## †ピットフォール
### 1. アップデート  
外から持ってきているので`conda update XXXX`とできない.  
PyPI側でアップデートがあった場合, もう一度`conda skeleton pypi XXXX`からやる.  

### 2. `conda skeleton pypi XXXX`からの`RuntimeError: directory already exists`  
入れたいパッケージと同名のフォルダがある場所でskeletonを使うと怒られるので関係ないところでやる.  
ホームディレクトリが楽なのでそのままやっているけど`conda build purge`とかもあるので一応ケアする.  

### 3. `conda build XXXX`からの`ModuleNotFoundError:`  
これはパッケージに不具合がある可能性が高い...  
自作時にしか対応できないが, 当該モジュールをrequirementに指定すると解決することがある.  


***
# ■ Anaconda cloudにパッケージを公開する
## 対象
* 自作したパッケージをanaconda cloudに公開したい人  

## 前提
既にcondaパッケージのbuildは終えている.  
終えていなければ上記を参考に.  

## 参考
[参考にさせていただいたサイトさん](https://iroha.daizutabi.net/anaconda/)  

## 方法
### ワークフロー
1. condaパッケージのbuild  
1. anaconda cloudアカウントを作成する  
1. anaconda-clientのインストール  
1. anaconda cloudにログイン  
1. アップロード  
1. 確認  
  
### 1. condaパッケージのbuild  
上記などを参考に.  
`conda build <PACKAGE> -c conda-forge`としておくとrequirementに入れているpython非公式なパッケージのインストールも一緒にできるので良き.  

### 2. anaconda cloudアカウントを作成する  
[サイト](https://anaconda.org/)にアクセスして普通に作成.  

### 3. anaconda-clientのインストール  
自分の使っている/使いたい環境を`conda activate XXXX`した後, `conda install anaconda-client`  
これで当該環境にて`anaconda`コマンドが使えるようになる.  

### 4. anaconda cloudにログイン  
`anaconda login`でログインする. 2.で作成したID/PWが要求される.  

### 5. アップロード  
    
    cd C:\Users\XXXX\Anaconda3\conda-bld\win-64 # buildされたファイルのディレクトリまで移動.  
    anaconda upload XXXX-0.0.1-py36_0.tar.bz2 # buildされたファイルをアップロード, だいたいこんな名前.  
    
### 6. 確認  
実際にインストールして確認する.  
`conda install -c my_ID XXXX`  
    * IDをチャンネル指定してXXXXパッケージをインストールする.  

### †ピットフォール
#### チャンネル指定必須  
anacondaでのパッケージ管理は全てチャンネルベースで行われている模様.  
チャンネル未指定でいけるものはもちろんのこと, 有名なconda-forge等に登録されているものも然るべき手続きを経て登録されているようだ.  
ゆえ, それらの基準を満たすメンテナンス等に自信がない間は自身のチャンネルを指定して公開する.  
`conda search XXXX`や`conda install XXXX`も全て`-c`オプションでチャンネルを指定してやる.  

***
# ■未解決の問題
## - UnsatisfiableError
### 症状
自作モジュールをインストールしようとする際にpythonのversion違いを指摘されて止まる.  
デスクトップではインストール可能なのにノートだとできない.  
### 状況まとめ
* python_requirements的には問題ない, というか記述がない (setup.pyではpython>=3.6としているが, packageは>=3.7と言われる)  
* pipでのインストールは可能.  
* condaでbuildは可能.  
* condaで指摘に合わせたpythonを導入した環境を作っていれるとインストール可能.  
* python以外の怪しそうなmodule (setuptools, m2-patch, wheel)のバージョンは同じ.  
* pipのバージョンは異なる.  
* skeletonでbuildしたものをインストールしようとしても怒られる.  
* 管理者権限でも変化なし.  
