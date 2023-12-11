# PyPIにパッケージを公開する手順
* うちのラボではbaseを弄りたくないのでAnacondaで仮想環境を構築し, その中でpythonを扱っている.  
* 特にAnacondaに作ったpip用の仮想環境からPyPIに公開する手順をまとめておく.  
* [参考させていただいたサイトさん1](https://qiita.com/shinichi-takii/items/e90dcf7550ef13b047b5)  
* [参考させていただいたサイトさん2](https://deepblue-ts.co.jp/python/pypi-oss-package/)  

# 対象
* PyPIへパッケージ公開したい初学者さん向け.  
* **PyPIとのやりとり部分のみ**, setup.pyの内容やディレクトリ構成とかは既に済んでいる前提.  
* 全体的に重要なことは[こちらのサイトさん](https://qiita.com/Ultra-grand-child/items/7717f823df5a30c27077)がとてもわかりやすい.  

# 環境
* 2020/7/20  
* windows 10  

***
# ワークフロー
1. Anacondaのpip用仮想環境立ち上げ  
2. 公開に必要なパッケージの準備  
3. 認証ファイル (.pypircファイル) の準備  
4. 配布物の準備  
5. 配布物の確認  
6. テスト公開  
7. 本番公開  

## 1. Anacondaのpip用仮想環境立ち上げ
`conda activate XXXX # 予め用意したpip用仮想環境名`  

## 2. 公開に必要なパッケージのインストール
`pip install wheel twine # 同時に導入`  
* `wheel`がパッケージ作成に必要  
* `twine`が公開に必要  

### †ピットフォール
* wheelやtwine間でのパッケージの互換性が割とシビアなイメージ, あるwheelのバージョン (setuptools絡みがだいたい) でパッケージを作成するとあるtwineで認識できないとか.  
* 基本的にバージョンが新しければ問題ないので, 何かエラーが起きたらまず`pip install --upgrade wheel twine`しておくといい.  
* pip自体のアップデートもケアする`python -m pip install --upgrade pip`.  

## 3. 認証ファイル (.pypircファイル) の準備
* テキトーなeditor (うちはVScodeユーザーが多いか) で以下の内容のテキストファイルを作成  
    
    ```
    [distutils]  
    index-servers =  
      pypi  
      testpypi  
    
    [pypi]  
    repository: https://upload.pypi.org/legacy/  
    username: my_account_name # 本番用アカウント名  
    password: my_account_password # パスワード  
    
    [testpypi]  
    repository: https://test.pypi.org/legacy/  
    username: test_account_name # テスト用アカウント名>  
    password: test_account_password # パスワード  
    ```
    
* .pypircにファイル名を変更.  
* ホームディレクトリ直下に置いておく.  
    * パスが通ればいいので, そこら辺がわかるならどこにおいてもいい.  

## 4. 配布物の準備  
公開したいパッケージのディレクトリに移動してwheelを使う.  
同じ操作をした場合は, 先に生成ファイル (build, dist, XXXX.egg-info) を削除してから行った方が安全.  
    
    cd [公開したいパッケージのパス]
    python setup.py sdist bdist_wheel  
        
* パッケージ化というと語弊があるが, そんな印象で思っておくとよい.  
* wheel形式が何か気になったらpythonのパッケージ公開の歴史と共に学ぶといい, 偉大な先達の苦労とwheel形式のありがたさがわかる.  

## 5. 配布物の確認  
`twine check dist/*`  
上手くいっていればpassedと出る.  

### †ピットフォール
* 駄目な場合は生成ファイルを削除した後に適宜対策を講じて同じことを繰り返す羽目に.  
* 別で書いているが, setup.pyでの外部textの読み込みや, 引数指定の間違いなどが原因なことが多い.  

## 6. test PyPIへのアップロード (テスト)  
`twine upload --repository testpypi dist/*`  
上手くいっているかを[test PyPI](https://test.pypi.org/)にアクセスして確認する.  

### †ピットフォール
* 同じパッケージ名が先に公開されていると挙げられないので事前に確認する.  
* 自分のパッケージを更新したい際には, setup.pyのversionを更新する必要がある.  

## 7. PyPIへのアップロード (本番)  
`twine upload --repository pypi dist/*`  
上手くいっているかを,  
1. [PyPI](https://pypi.org/)にアクセス  
1. `pip install XXXX`で実際にインストール  
して確認する.  

### †ピットフォール
* PyPIへの公開と`pip install XXXX`でインストールできるまでにラグがある.  
* バージョンアップが反映されてない！？なんて驚かずにしばし待ってからやると反映される, どんと構えましょう.  
