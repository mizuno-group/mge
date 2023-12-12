# sysモジュールを使ったコマンドライン引数の受け取り方
 ここでは, Pythonでsysモジュールを使ってコマンドライン引数を受け取る方法について説明する。

 sysモジュールにおいてコマンドライン引数は, sys.argvという変数にリストとして格納されている。
```python: command.py
# command.py
import sys

for arg in sys.argv:
    print(f"Hello, {arg}")
```
このスクリプトを実行すると以下のようになる。
```
$ python command.py a b c
Hello, command.py
Hello, a
Hello, b
Hello, c
```
このように, sys.argv[0]は実行しているファイル名になる。また数字を指定しても全て文字列型で格納される。
