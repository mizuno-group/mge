# 220421
docker上でcode-serverを立てて, 普段のvscode likeな環境と同じように開発できるようにする  
jupyter labだと補完が微妙だったのでそこら辺を上手くやりたい  

# 参考
[メイン](https://qiita.com/YKIYOLO/items/06cf44dead84188677ae)  
[docker-composeをWSL2に入れる](https://zenn.dev/taiga533/articles/11f1b21ef4a5ff)  
[WSL2にssh接続する](https://qiita.com/yuta-katayama-23/items/fad6928f37badf3391f2)  
[WSL2にssh接続する2](https://scratchpad.jp/ubuntu-on-windows11-5/)  
- 普通のlinuxマシン的に扱えばOKっぽい  

# HowTo
1. WSL2のインストール  
    - 一般的な方法でやればよい  
2. WSL2内のsshの設定  
    - environmentを参照しながら一般的なsshの設定を行う  
    - win/wsl2双方にsshのインストール  
    - win側で鍵の準備  
    - pub_keyをwsl2に導入  
    - sshd_configの設定を弄る  
↑ここら辺いらないかも？  
他の計算機サーバーと同様にやるなら必要だが, WSL2内でシンプルにコンテナ立てればいけるんじゃ…？  
→　いけた  
混乱するが, WSL2の場合はhostのlinuxとwindowsが同じ127.0.0.1=localhostになっている  
計算機サーバーに接続する際にはWSL2にSSHで接続して飛ばす感じができるとよいか  

    version: '3.8'

    services:
    py3: # コンテナ名
        build:
        context: ./codesev # どこにdockerfileがあるか
        dockerfile: Dockerfile # dockerfile名
        restart: always
        command: code-server --port 8080 --bind-addr=0.0.0.0:8080 /workspace --log debug
        # --port: コンテナがさらすポート  
        # --bind-addr: おそらくどのポートとどのポートをつなげるか, 0.0.0.0はなんでもOKで, それとコンテナの8080をつないでいる  
        # /workspace: おそらくコンテナ内のworking dir
        ports:
        - '127.0.0.1:8080:8080'
        # 127.0.0.1は自分, localhostのこと。これとホストのポート, コンテナのポート  
        environment:
        - PASSWORD=wsl24771
        # PWが接続時に聞かれる。クォーテーション不要
        volumes:
        - type: bind
            source: /mnt/d/mydata/workspace
            target: /workspace
            # ここはいつもどおり, sourceがホスト側(wsl2), targetがcontainer側
        tty: true
        deploy:
        resources:
            limits:
            cpus: '0.9'


使用時はwsl2を起動して, 該当のdocker-composeがあるdirにcdし, docker-compose up -dする  
ついでlocalhost:8080にアクセスして, 設定したPWを入力すればOK  