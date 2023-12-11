# WSL2 + docker + vscode環境の構築
windows10にてdockerベースで管理しながらlinuxでの開発環境構築ができる  
WSL2にubuntuを載せ, そこでdocker環境を作り, vscodeでhostとやりとりできるようにした感じ  
windowsでの操作性＋linux/dockerの開発環境という感じですごく扱いやすい  

## 日付
2021/7/24  

## 参考
[参考1](https://speakerdeck.com/nsaito9628/wsl2-plus-docker-plus-jupyter-to-vs-code-rimotohuan-jing-falsegou-zhu?slide=16)  
[参考2](https://qiita.com/c60evaporator/items/fd019f5ac6eb4d612cd4)  

***
# 大まかな流れ
1. WSL2導入  
2. ubuntu distribution導入   
3. docker desktop導入  
4. vscodeにRemote Development (extension)を導入  
5. vscodeに対応した形でDockerfileを準備  
6. image作成, コンテナ作成, vscodeからアクセス  

***
# 詳細
## 1-4.
1-4までは全く迷うことはないはず, 必要があればgoogle先生に聞けば十分  

## 5. vscodeに対応した形でDockerfileを準備
以下が必要  
- WORKDIRの指定 (変える必要あり)  
    - WSL2/ubuntu上のどこを作業スペースにするか  
    - /home/{user_name}/{workspace}といった感じになる  
- ENTRYPOINT (変える必要あり)  
    - 重要, ここでコンテナ起動時のjupyterlabとのやりとりを決定している  
    - ここでもポートの指定が必要,   
    - --NotebookApp.token=''を使うことでPWの要求をさぼっている  
- CMD (変える必要あり)  
    - 重要, ここでもコンテナ起動時のjupyterlabとのやりとりを決定している  
    - ポートの指定と使用するデフォルトのworkspaceのパスが必要  
- EXPOSEの指定  
    - コンテナ側のリッスンポート  
    - jupyterlabが8888をデフォにしているらしいので基本8888か  
    - 変えれば複数立てることができそうか (未トライ)  
※具体例は最後の方に載せておく

## 6. image作成, コンテナ作成, vscodeからアクセス
### image作成  
- 一般的な方法  
- Dockerfileのあるディレクトリで行うので, プロジェクトごとにディレクトリを分けておく必要がある  
- WSL2/ubuntuのターミナルを使う  
- workspaceに移動した後に```docker build -t {つけたいimage名} .```  
- 最後の.を忘れないように  
- ```docker images```で確認できる  

### コンテナ作成  
- workspaceにて以下  
- ```docker run -it -p 8888:8888 --rm --name {つけたいコンテナ名} --mount type=bind,src=/mnt/c/Users/{winのユーザー名}}/{作業フォルダ名},dst=/home/{user名}/{作業場明} {作成したimage名}```  
    - ```-p 8888:8888```の部分はポート次第で変更, Rの場合は8787:8787  
- コマンドが長くてだるいが現状仕方がない  
- docker-compose.ymlを使えるらしいがなぜか上手くいっていないので今後の検討事項  
- ```docker ps -a```で確認できる  
- ```--rm```引数によりコンテナ終了後, 自動的に破棄するかどうかを決めれる。コマンドが面倒なので外してもいいかも  
- 上記でrunするとコンテナ作成と同時にコンテナがrunされる  
- コンテナを残している場合には, ```docker start {コンテナ名}```で開始でき, ```docker stop {コンテナ名}```で止められる  

### vscodeから開く  
- 上記のようにubuntuターミナルでdockerをrunした状態でvscodeの左下の><のようなマークを押下する  
- ```Attach to Running Container...```のようなものが出てくるのでこれを押下  
- 起動中のコンテナが出てくるので押下すると新しいwindowでvscodeが開かれる  
    - 出てこない場合は別のリモートセッションをしているvscodeを開いていることが多い。この場合は><と同じ位置を押下して```close remote session```してから行うと通る  
- vscodeのextension (□4つ) からpythonを検索　→　install on container...となっていたらインストールする, 既にされていればスキップ  
- vscodeのリモートエクスプローラー (PCアイコンに><) を開き, PC作業フォルダ(保存先)と仮想dirがbindされていることを確認  
- vscodeのエクスプローラー (テキスト2枚重なってる奴) を開き, コンテナをrunしたubuntu側のフォルダ名を入力  
- 以上で使えるようになる  

***
# 使い方
↑の5, 6で開始できる  
終了は以下の手順  
- ><と同じ位置を押下して```close remote session```し, 開いていたvscodeを閉じる  
- ubuntuターミナルでctrl + c -> yにてコンテナ終了  
    - ctrl + p + qでdetatchするとコンテナを終了せずに離れることができる  

***
# 雑感
vscodeで開くまでの手順はいくらかあるっぽい  
現状だとポートが同じとされて複数のコンテナを同時に走らせて同時に別窓のvscodeで見るといったことができない  
ポートを変えたらいけそうだった (検証途中)  
pythonは[jupyterが出しているimage](https://hub.docker.com/r/jupyter/scipy-notebook)を使うのが現状良さそう  
Rはjupyterに落とす意味があまりないので, dockerで8787ポートにつなぎ, localhost:8787でブラウザからrstudioを動かす形に落ち着いた  

# TIPS
- WSL2のubuntuターミナルにて```code .```とすると対応するvscodeが開ける  

# ToDo
- Dockerfileの管理をgithubで行えるようにする  
- ポートの対応と変えられないかどうかの評価  
- pythonのバージョン変更どうするか  
- docker runではなくdocker-composeを使うためのベストプラクティス  
- docker hubとの連携  
- Dドライブとの連携方法模索  

***
# Dockerfileの参考

    ```
    FROM jupyter/scipy-notebook

    RUN conda install -c conda-forge tqdm && \
        conda clean --all -f -y

    WORKDIR /home/{ユーザー名}/{作業場}

    EXPOSE 8888 # ポートを変えるなら変更

    ENTRYPOINT ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''"]
    # 上に同じ

    CMD ["--notebook-dir=/home/{ユーザー名}/{作業場}"]
    ```

- RUNは&&でつないで書く, レイヤー数を減らして容量削減につながる  
