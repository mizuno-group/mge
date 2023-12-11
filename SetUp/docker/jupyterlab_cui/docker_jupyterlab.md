# Linuxサーバーにdockerのjupyter lab環境を作ってクライアントPCに飛ばす
GUIは要らないけどjupyter-labくらいは使いたいという時用  

# 概要
- コンテナのポート → 計算機サーバーのポート → クライアントPCのポートとポートフォワーディングでつなぐ  
- jupyterの[テンプレ](https://jupyter-docker-stacks.readthedocs.io/en/latest/index.html)を元にしたdockerfileにjupyter-labの起動周りを組み込んでコンテナを作成し, クライアントPCと計算機サーバーとでローカルポートフォワードをすればいい  

# できること
- クライアントPCで指定したポートを覗くとコンテナ環境内のjupyter-labが使える  
- もちろん端末も開けるのでCLIやpackageのインストールも可  

# 環境
- 21/08/10  
- クライアントPC： Windows10 pro (proじゃなくても可)  
- 計算機サーバー: ubuntu20.04 (他は試していない)  
- リモート接続ソフト: MobaXterm (powershellでもなんでも可)  

***
# 1. Dockerfileの準備
以下のように準備する  
適宜{XXXX}は自身の環境に読み替える  

    
    FROM jupyter/scipy-notebook

    # 同じ内容のものはできる限り&&でつないでレイヤー数を減らす
    # conda clean --all -f -y: キャッシュを削除して容量を減らす
    # pipも同じ感じだが, キャッシュ削除がバージョンによってやりづらい
    RUN conda install -c bioconda -c conda-forge salmon && \
        conda install -c bioconda -c conda-forge prinseq-plus-plus && \
        conda clean --all -f -y

    EXPOSE {SSHサーバーにリッスンさせるポート, 8888とか}

    # コンテナ起動時にrunする内容, root allowとかnotebookのtoken無視とか本当はやっちゃいけない
    ENTRYPOINT ["jupyter-lab","--ip=0.0.0.0","--port={↑のポートに同じ}","--no-browser","--allow-root","--NotebookApp.token=''"]


# 2. 計算機サーバーへのSSH接続
mobaxterm使うなりpowershell使うなりなんでもいいので計算機サーバーへSSH接続する  
鍵とか整えた後以下の感じ  
```ssh -i {秘密鍵のパス} -p {計算機サーバーで開けているポート番号} {計算機サーバーのユーザー名}@{計算機サーバーのIP}```


# 3. Tunneling
ローカルポートフォワード (クライアントPCのあるポートを覗いたらサーバーが提供する別のポートが覗ける) しておく  
設定を変更した後は一度SSH接続をオフして再度接続することで反映される  

## クライアント
クライアントPCでjupyter-labを覗くときに使いたいポート番号を指定  
well-known portやら予約済み関係, ないし自分が他に使っていないものであればなんでもいい (ex. 8080)  

## SSHサーバー (踏み台)
計算機サーバーのIPアドレス, 計算機サーバーのユーザー名, SSH接続に使用している開放されたポート番号を指定する  

## リモートサーバー
計算機サーバー自体なのでホスト名はlocalhostでよい  
コンテナのポートを受ける計算機サーバーのポート番号を指定 (ex. 6080, ここが少しわかりづらいか)  


# 4. コンテナの作成
## イメージの作成
Dockerfileのあるディレクトリで```docker build -t {作成したいコンテナ名} .```  
最後の``` .```を忘れないこと  

## コンテナの作成 v1
以下のコマンドでコンテナを作成  
```docker run -it -p {0}:{1}} --name {2} -v {3}:/home/jovyan/work {4} ```  

- 0: 3.で指定したリモートサーバーのポート  
- 1: 1.で指定したコンテナのポート  
- 2: コンテナ名  
- 3: コンテナ内と共有したいホストPC内のディレクトリのパス  
- 4: 4.で作成したイメージの名前  

具体例  
```docker run -it -p 6080:8888 --name my_ctn -v "PWD":/home/jovyan/work my_img ```  
- "PWD"は現在のディレクトリ  

### 補足
```-v {計算機サーバー内の領域}:{docker内の領域}```という形でマウントできるので変えたければ適宜変える  
相対パスは使えない模様  
デフォではカレントディレクトリをdocker内の```/home/jovyan/work```にマウントする設定  
```/home/jovyan/work```はjupyterのテンプレを走らせると作成されるものなのでそのまま流用  

## コンテナの作成 v2
```-v```オプションは短くて済むが, 公式は明示的な```--mount```をオススメしている  
```docker run -it -p {0}:{1}} --name {2} --mount type=bind,src={3},dst=/home/jovyan/work {4} ```  

- 0: 3.で指定したリモートサーバーのポート  
- 1: 1.で指定したコンテナのポート  
- 2: コンテナ名  
- 3: コンテナ内と共有したいホストPC内のディレクトリのパス  
- 4: 4.で作成したイメージの名前  

具体例  
```docker run -it -p 6080:8888 --name my_ctn --mount type=bind,src=/mnt/data1,dst=/home/jovyan/work my_img ```  


# 5. jupyter-labの起動
3.で指定したクライアントPCのポートにブラウザでアクセスすれば所望のコンテナ環境のjupyter-labが起動する  
LauncherでNotebook/Python3を選べば通常通りipynbが使える  
Other/terminalで端末が使える  
CLIを使いたいときやpackageインストールしたいときはterminalを使えばいい  


***
# オマケ
# r-notebook
Rについても以下のようなDockerfileを記述すれば, jupyter notebook形式で作成できる  
注意点として, ```install.packages()```やらを使う際にrepositoryを指定しておく必要がある  
指定しないとGUI操作でrepositoryを指定する操作を要求されるためかエラーとなる  

    FROM jupyter/r-notebook

    RUN R -e "install.packages('BiocManager',repos='https://cran.ism.ac.jp/')" && \
        R -e "BiocManager::install('tximport')"

    EXPOSE 8888

    ENTRYPOINT ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''"]


# python & r
jupyterからdatascience notebookが出ているが, dockerfileレベルでのパッケージインストールをするとエラーが出やすいこと, 普段は使わないjuliaが入っていて重いことが課題  
scipy-notebookに大して上記のRの記述を入れるとそこが解決する  
python, R, それぞれパッケージをインストールしておきたい場合に弄る場所が中途半端なので注意 (本当はもっと上手く書けるはずだが…)  


    FROM jupyter/scipy-notebook

    ### pythonに入れたいパッケージをここでインストール ###
    RUN conda install -c bioconda -c conda-forge salmon && \
        conda install -c bioconda -c conda-forge prinseq-plus-plus && \
        conda clean --all -f -y


    ##############################################################
    # ↓↓↓　触らない　↓↓↓
    USER root

    # Fix DL4006
    SHELL ["/bin/bash", "-o", "pipefail", "-c"]

    # R pre-requisites
    RUN apt-get update --yes && \
        apt-get install --yes --no-install-recommends \
        fonts-dejavu \
        gfortran \
        gcc && \
        apt-get clean && rm -rf /var/lib/apt/lists/*

    # R packages including IRKernel which gets installed globally.
    RUN conda install --quiet --yes \
        'r-base' \
        'r-caret' \
        'r-crayon' \
        'r-devtools' \
        'r-forecast' \
        'r-hexbin' \
        'r-htmltools' \
        'r-htmlwidgets' \
        'r-irkernel' \
        'r-nycflights13' \
        'r-randomforest' \
        'r-rcurl' \
        'r-rmarkdown' \
        'r-rodbc' \
        'r-rsqlite' \
        'r-shiny' \
        'r-tidymodels' \
        'r-tidyverse' \
        'rpy2' \
        'unixodbc' && \
        conda clean --all -f -y && \
        fix-permissions "${CONDA_DIR}" && \
        fix-permissions "/home/${NB_USER}"

    WORKDIR "${HOME}"

    # ↑↑↑　触らない　↑↑↑
    ##############################################################

    ### pythonに入れたいパッケージをここでインストール ###
    RUN R -e "install.packages('BiocManager',repos='https://cran.ism.ac.jp/')" && \
        R -e "BiocManager::install('tximport')"


    # dockerのポートの指定
    EXPOSE 8888

    ENTRYPOINT ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''"]


# scp
Dockerfileを弄っているとき頻繁にscpするので残しておく  
``` scp -i {秘密鍵のパス} -P {計算機サーバーのポート} {クライアントPCのコピー元ファイルパス} {計算機サーバーのユーザー名}@{計算機サーバーのIP}:{計算機サーバーのコピー先 (ディレクトリまででOK)} ```


# jupyterlabではなくvscodeで受ける
どうやらinsider版とやらのvscodeを使うと, SSH接続からコンテナの出力を受けることもできるらしい？  
現時点では未検証 ([参考](https://qiita.com/kanosawa/items/07e26edb19c86091fa48))  