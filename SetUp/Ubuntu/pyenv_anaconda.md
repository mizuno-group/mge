# ■ python環境構築
pyenvを使ってanacondaを入れるのが一般的な模様.  
Maederaの投稿にあった[ここ](https://obenkyolab.com/?p=43)が参考になるが, 記事の内容に細かな誤りがあるので注意する.  

## 1. pyenvのインストール
1-1. pyenvに必要なパッケージのインストール  
    ```sudo apt install git gcc make openssl libssl-dev libbz2-dev libreadline-dev libsqlite3-dev zlib1g-dev```  

1-2. gitのpyenvリポジトリをclone  
    ```
    cd /home/[usrname]
    git clone https://github.com/yyuu/pyenv.git ~/.pyenv
    ```
* なんかURLがcentosと違ったけど、、、どういうこと

1-3. PATHの設定等
[参考](https://qiita.com/u_kan/items/d7e602bf1cf52f6b0935)

    echo 'export PYENV_ROOT="[path]/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    source ~/.bashrc
    
    sudo visudo
    以下のように変更する
    # Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin  コメントアウト
    Defaults    env_keep += "PATH"  # 追加
    Defaults    env_keep += "PYENV_ROOT"  # 追加
    
## 2. anacondaのインストール
2-1. インストール可能なanaconda ver.リストを確認  
    ```pyenv install --list | grep anaconda```  
 
2-2. 最新バージョンのインストール  
* DLしている間変化がないのでフリーズしたように見えるが動いてる    
```sudo pyenv install anaconda3-5.3.1```
 
2-3. 環境設定とか
    
    pyenv rehash
    pyenv global anaconda3-5.3.1
    echo 'export PATH="$PYENV_ROOT/versions/anaconda3-5.3.1/bin/:$PATH"' >> ~/.bashrc
    source ~/.bashrc  
 
2-4. 本体アップデート
* ここまでくれば普通にcondaコマンドが使える?  
    
    ```
    sudo conda update conda
    python --version   
    ```
***
# ■ NGS用の環境構築
* [PRINSEQ++](https://github.com/Adrian-Cantu/PRINSEQ-plus-plus)  
* 行けるかわからないので誰か確認してください（200912）  

    ```
    conda create -n ngs
    conda activate ngs
    conda install -c bioconda -c conda-forge prinseq-plus-plus
    conda install -c bioconda salmon
    conda install R
    ```

## Rのpackage install
    ```
    (conda init) 必要かわからない 
    R
    以下、R console
    if (!requireNamespace("BiocManager", quietly = TRUE))
        install.packages("BiocManager")
    BiocManager::install("tximport")
    install.packages("jsonlite")
    install.packages("readr")
    q()
    n
    '''
* これで水野班でのRNAseq解析フローは回せるはず？

***
# ■ Chromeのinstall

* [homepage](https://www.google.com/intl/ja_jp/chrome/)よりdownload
* そのままだと足りないpackageがある（罠）
    ```
    sudo apt install libappindicator1
    sudo dpkg -i [deb fileへのpath]
    ```
* google-chromeもしくはアクテビティから起動できるようになる

***
# その他
* 端末の動作がおかしかったらbashrcやbash_profileのpathを確認すべし
* conda update condaでpython3.6がないとのerrorが出た、が、uninstallしてやり直したら通った。
