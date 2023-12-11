# rdkit 環境構築まとめ

rdkitを扱っていると他のパッケージとの兼ね合いに苦戦することが多いため、ここでまとめておく  
初版：201023

### rdkit注意点
- pipがない（pipがない理由をwebページ使ってつらつら書くレベル）
- かといってソースからビルドするのもPATHがややこしすぎるので推奨しない
- したがってできる限りcondaで落とす。rdkit環境でpipを使いたければskeletonでcondaパッケージをビルドしたほうが安全。またこの点から必ず仮想環境で扱うべき
- しかしcondaもrdkitチャンネルとconda-forgeチャンネルが存在して違うものが提供されるので注意が必要。

### install方法

仮想環境構築時に同時に入れる場合は、`conda create -n <name> -c rdkit[conda-forge] rdkit` でよいし、普通に入れたければ通常のcondaのインストールを使えばよい  

同時に入れた場合、rdkitチャンネルならPython3.7.9、conda-forgeならPython3.7.6がインストールされる。   
関係ないが昔はrdkitチャンネルだと3.6.12だった。ようやくupdateしたっぽい  

(210408) conda-forgeでrdkitをインストールすると、python 3.9.2, rdkit 2021.03.1がインストールされた。


### tips
- spyderとrdkitがうまく合わない(おそらくpyqt周り)。
	- (201204) そもそもpython3.9だとspyderが入らない 
	- python3.7で仮想環境構築→spyder→rdkitチャンネルからrdkit→その他ケモインフォ系パッケージ(conda-forge) の順ではうまくいった
	- python3.8はconda-forgeチャンネルのみspyderと共存可。他のパッケージをconda-forgeに合わせれば問題なさそう
- openbabelはconda-forgeだとv3.1.1だがopenbabel channelではv2.4.1がやってくる。pybelの呼び出し方が異なってくるので依存関係に注意が必要。なおPLIPは内部にopenbabelを抱えており、conda-forgeで先に入れているとconflictする
- rdkit以外をpipで揃えれば環境破壊が起きないのかどうかは不明


## Pytorchとrdkitの共存
非常に厳しい思いをしている。  
**rdkit以外はpipで入れるのがよい**

```bash
$ conda create -n chemoinfo python=3.8
$ conda activate chemoinfo
$ conda install -c conda-forge rdkit
$ pip install jupyter jupyterlab nodejs spyder

# pytorchのダウンロード
$ pip install -c torch torchvision torchaudio
$ pip install torch-scatter torch-sparse torch-cluster torch-spline-conv -f https://pytorch-geometric.com/whl/torch-<version>+cu<version(no period)>.html

# 諸ツール(主にopenbabel)のダウンロード
$ pip install e3fp
$ git clone https://github.com/openbabel/openbabel.git
$ sudo apt install libxml2-dev zlib1g-dev libwxgtk3.0-dev libboost-all-dev libomp-dev libeigen3-dev libcairo2-dev
$ cd openbabel 
$ mkdir build
$ cd build
$ cmake -DCMAKE_INSTALL_PREFIX=${HOME}/openbabel-3.1.1 -DENABLE_OPENMP=ON -DBUILD_GUI=OFF -DPYTHON_EXECUTABLE=<python path in created environment> -DPYTHON_BINDINGS=ON -DRUN_SWIG=ON
$ make -j <the number of cpu>
$ sudo make install
$ pip install plip
# 適宜pathを設定。openbabelのpathと共有ライブラリのpath。



