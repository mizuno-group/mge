# fireを使った関数のコマンドライン化
Pythonでfireというパッケージを使うと, 関数を簡単にCLIで使えるようにできる。

## 基本的な使い方
Fire関数をインポートして, CLIで使いたい関数をFireに渡す。
```python: sqrt.py
#sqrt.py
from fire import Fire

def sqrt(x):
  return x**2

Fire(sqrt)
```
これで関数を実行できるようになる。
```
$ python sqrt.py 2

# 実行結果
4
```

## 指定した変数の型
変数の型変換も自動で行ってくれ, 例えば12と指定すればint型, abcと指定すればstr型になる。また, [1,2,3]のように指定するとリストも指定できる。タプルや辞書も同様。しかしリストやタプル, 辞書は','の前後などに空白を開けてしまうと指定できない。  

以下ではFireの色々な機能を述べる。

## プログラムのヘルプを表示する
argparse同様, fireでも自動でプログラムのヘルプが作成されており, -hまたは--helpオプションで参照できる。
```
# コマンドライン
$ python sqrt.py --help

# 実行結果
INFO: Showing help with the command 'sqrt.py -- --help'.

NAME
    sqrt.py

SYNOPSIS
    sqrt.py X

POSITIONAL ARGUMENTS
    X

NOTES
    You can also use flags syntax for POSITIONAL ARGUMENTS

```

## 複数の引数を持つ関数
引数が複数ある関数もコマンド化できる。コマンドライン上で渡した引数は順番通り関数の引数に渡されるが, --のオプションで引数を指定できる。pythonと異なり--オプションの後にオプションなしの引数を指定してもよい。
```python: greet.py
# greet.py
from fire import Fire

def greet(name, age):
  print(f"Hello, {name}. You are {age} year(s) old.")

Fire(greet)
```
```
$ python greet.py --age 50 "Professor Kusuhara"

# 実行結果
Hello, Professor Kusuhara. You are 50 year(s) old.
```

## 複数の関数をコマンド化する
これまでの例では1つの関数しかコマンド化できないが, 複数の関数をコマンド化するにはFireに{<コマンド名>: 対応する関数} の辞書を渡す。
```python:minmax.py
# minmax.py
from fire import Fire

Fire({"MIN":min, "MAX":max})
```
実行するときはコマンド名を指定する。
```
# コマンドライン
$ python minmax.py MIN [1,2,3]

# 実行結果
1
```

## Fire()のように空にした場合
Fireに何も渡さなかった場合, その.pyファイルに含まれている全ての変数, 関数を登録する。

## 参考文献
・公式ドキュメント  
https://docs.pyq.jp/column/fire.html  
主に参考にしました。