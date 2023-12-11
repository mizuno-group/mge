conda packageの作成方法備忘録.  
PyPIの方は作成が簡単だがcondaの方は結構やっていることが複雑っぽい.  
現状, 結構多くのパッケージでbuild時のエラーが出る印象を持っている.  

# ■ 対象  
* conda packageを作成したい人  
* PyPIへのアップロード方法は知っているけどcondaに関してはよくわからない人  

# ■ 前提
* PyPIで一般に使用されているパッケージの形式を知っている  
* PyPIに当該パッケージをアップロード済み  

# ■ 環境
* windows10, python 3.7  
* CPU: Intel(R) Xeon(R) E-2246G CPU @ 3.60GHz 3.60GHz  
* RAM: 64.0 GB  
* 2020/8/15  

***
# ■ ワークフロー
1. PyPIパッケージを元にcondaパッケージをビルド  
1. anaconda cloudにアップロード  

# ■ 具体的な方法
1. PyPIパッケージを元にcondaパッケージをビルド  
[参考](https://analytics-note.xyz/mac/conda-skeleton-pypi/)  

    1. pypiパッケージを入れたい仮想環境をactivateする.  
    `conda activate [environment name]`

    1. patchがないと怒られるのでこの環境に入れたことなければインストールする.  
    `conda install m2-patch`
        * windowsの場合はこれ. 他のOSだと違う (CentOSならyumでpatchとか)  

    1. skeltonを使ってcondaパッケージの作成.  
    `conda skeleton pypi <PACKAGE>`    
        * カレントディレクトリにできるので上書き注意. たぶんどこでやってもいいはず.  

    1. ビルド  
    `conda build <PACKAGE>`
        * buildの際に`conda build <PACKAGE> -c conda-forge`とすることで指定したチャンネルに属しているrequirementも拾ってくれるっぽい.  
        * 依存関係の中に特定のチャンネルのものが入っている場合も同様にチャンネル指定する必要がある`conda build <PACKAGE> -c XXXX`

    ## †ピットフォール
    1. `conda skeleton pypi XXXX`からの`RuntimeError: directory already exists`  
    入れたいパッケージと同名のフォルダがある場所でskeletonを使うと怒られるので関係ないところでやる.  
    ホームディレクトリが楽なのでそのままやっているけど`conda build purge`とかもあるので一応ケアする.  

    1. `conda build XXXX`からの`ModuleNotFoundError:`  
    これはパッケージに不具合がある可能性が高い...  
    自作時にしか対応できないが, 当該モジュールをrequirementに指定すると解決することがある.  

1. anaconda cloudにアップロード  
[参考](https://iroha.daizutabi.net/anaconda/)  

    1. anaconda cloudアカウントを作成する  
    [サイト](https://anaconda.org/)にアクセスして普通に作成.  

    1. anaconda-clientのインストール  
    自分の使っている/使いたい環境を`conda activate XXXX`した後, `conda install anaconda-client`  
    これで当該環境にて`anaconda`コマンドが使えるようになる.  

    1. anaconda cloudにログイン  
    `anaconda login`でログインする.  
    2.で作成したID/PWが要求される.  

    1. アップロード  
    
        cd C:\Users\XXXX\Anaconda3\conda-bld\win-64 # buildされたファイルのディレクトリまで移動.  
        anaconda upload XXXX-0.0.1-py36_0.tar.bz2 # buildされたファイルをアップロード, だいたいこんな名前.  
    
    
    1. 確認  
    実際にインストールして確認する.  
    `conda install -c my_ID XXXX`  
        * IDをチャンネル指定してXXXXパッケージをインストールする.  

    1. お片付け
    * skeletonが作成したフォルダ等が残っているので削除する.  
    * buildしたパッケージも`conda build purge`で削除する.  
      
    ## †ピットフォール
    1. チャンネル指定必須    
    anacondaでのパッケージ管理は全てチャンネルベースで行われている模様.  
    チャンネル未指定でいけるものはもちろんのこと, 有名なconda-forge等に登録されているものも然るべき手続きを経て登録されているようだ.  
    ゆえ, それらの基準を満たすメンテナンス等に自信がない間は自身のチャンネルを指定して公開する.  
    `conda search XXXX`や`conda install XXXX`も全て`-c`オプションでチャンネルを指定してやる.  

    1. anaconda cloudに上がってからinstall可能になるまでのラグ    
    そこそこ (下手すると数時間単位？) のラグがある時がある.  
    versionアップしたはずなのに反映されない！？とハマったことがあるのでどんと構えましょう.  


***
# ■ 未解決の問題
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
