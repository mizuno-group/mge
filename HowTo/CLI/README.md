ここでは, PythonプログラムをCLIベースで動かす方法について説明する。

# 概要
CLIとはCommand Line Interfaceの略。  
Pythonプログラムはjupyter notebookなどで実行できるが, WindowsのAnaconda PromptやLinuxのターミナル(以下「コマンドライン」)から動かすこともできる。

# 基本的な使い方
テキスト形式でPythonのコードを作成して保存すると, プログラムをpythonコマンドで実行できる。
```python: test.py
#　例: test.py
print("Hello world!")

```
```
$ python test.py

# 実行結果
Hello world!
```

# コマンドライン引数の指定
.pyプログラムにコマンドライン引数を指定することもできる。
```
$ python test.py arg1 arg2 ...
```


.pyプログラム側が引数を受け取る方法については, [sysモジュールを使う方法](sys.md)/[argparseを使う方法](argparse.md)/[Fireを使う方法](Fire.md)がある。詳しくはそれぞれの項目を参照。個人的にはargparseを使う方法が最も使いやすく, よく使われている印象がある。


# プログラムのコマンド化
よく使うプログラムの場合, CLIツールにすることでコマンドのようにさらに簡単に実行できるようになる。CLIツールを作成すると以下のように実行できる。
```
$mytool arg1 arg2 ...
```
詳しくは[CLITool](CLITool.md)の項を参照。