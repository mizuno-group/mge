# argparseを使ったコマンドライン引数の受け取り
ここでは, Pythonでargparseモジュールを使ってコマンドライン引数を受け取る方法について説明する。  

## ・基本的な使い方  

最も簡単なargparseの使い方は以下のようなものである。  
①parserの作成  
②必要な引数の追加  
③引数の取得  
具体的には以下のようなコードになる。
```python: test.py
# test.py
import argparse

# 1.parserの作成
parser = argparse.ArgumentParser()

# 2.引数の追加
parser.add_argument("arg1") # "arg1"の部分は自分の設定したい名前にする。
parser.add_argument("arg2") # 複数追加してもよい。

# 2.引数の取得
args = parser.parse_args()
arg1 = args.arg1 # 指定した名前と同じ属性がargsにあり, そこに引数が格納されている。
print(arg1)
```
これに引数を指定して実行すると以下のようになる。
```
$ python test.py a b

# 実行結果
a

```

argparseには便利な機能がいくつかある。以下でその一部を紹介する。

### ・引数の型を指定する
 引数は, デフォルトではすべてstr型で読み込まれる。引数の型を指定するにはadd_argumentでtypeを指定する。
 ```python test.py
parser = argparse.ArgumentParser()
parser.add_argument("arg1", type=int) 
args = parser.parse_args() 
print(type(args.arg1))
```
```
$ python test.py 123
<class 'int'>
```
typeには, 1つの文字列を受け取る関数(もしくはcallable)も指定できる。
```test.py
parser = argparse.ArgumentParser()
parser.add_argument("file", type=open) 
args = parser.parse_args()
lines = args.file.readlines()
...
```

## ・ヘルプを表示する
argparseで引数を指定した場合, 何もしなくても以下のように -h オプションでヘルプが表示されるようになっている。
```
$ python test.py -h
usage: test.py [-h] arg1 arg2

positional arguments:
  arg1
  arg2

optional arguments:
  -h, --help  show this help message and exit
```

## ・プログラムのヘルプを追加する
--helpオプションでプログラム全体の説明を表示させたい場合, argparse.ArgumentParser()にdescriptionを追加する。
```python: test.py
import argparse
parser = argparse.ArgumentParser(description="Print arg1.")
parser.add_argument("arg1") 
parser.add_argument("arg2") 
args = parser.parse_args() 
arg1 = args.arg1 
print(arg1)
```
```
$ python test.py -h
usage: test.py [-h] arg1 arg2

Print arg1.

positional arguments:
  arg1
  arg2

optional arguments:
  -h, --help  show this help message and exit
```

## ・それぞれの引数のヘルプを追加する
 それぞれの引数に説明を加えたい場合はadd_argumentでhelpを指定する。
 ```python: test.py
import argparse
parser = argparse.ArgumentParser(description="Print arg1.")
parser.add_argument("arg1", help="Argument1. will be printed.") 
parser.add_argument("arg2", help="Argument2. will be ignored.") 
args = parser.parse_args() 
arg1 = args.arg1 
print(arg1)
```
```
$ python test.py -h
usage: test.py [-h] arg1 arg2

Print arg1.

positional arguments:
  arg1        Argument1. will be printed.
  arg2        Argument2. will be ignored.

optional arguments:
  -h, --help  show this help message and exit
```


### ・オプション引数を指定する
 これまでは, コマンドで引数だけを指定させる位置引数について説明したが, '-a'や'--a'のようにオプション引数を指定することもできる。
 ```python: test.py
parser = argparse.ArgumentParser()
parser.add_argument("arg1") 
parser.add_argument("arg2")
parser.add_argument("--option1") 
args = parser.parse_args() 
print(args.arg1)
print(args.arg2)
print(args.option1)
 ```
位置引数とオプション引数は-, --の有無によって区別される。  
コマンドラインで引数を渡すとき, 位置引数の間にオプション引数を入れて指定することもできる。その場合, 全ての渡された引数からオプション引数を除いたうえで, 渡された引数が順番に位置引数に代入される。
```
$ python test.py apple --option1 banana cheese
apple
cheese
banana
```

### ・オプション引数にデフォルト値を指定する。
 オプション引数が指定されなかった場合のデフォルト引数は, add_argumentのdefaultパラメタで指定できる。
```python: test.py
parser = argparse.ArgumentParser()
parser.add_argument("arg1") 
parser.add_argument("--option1", default="no_value")
args = parser.parse_args() 
print(args.arg1)
print(args.option1)
 ```
 ```
$ python test.py apple
apple
no_value
 ```
defaultのデフォルト値はNoneである。つまり, defaultを指定せず, かつオプション引数が指定されなかった場合, オプション引数にはNoneが代入される。

### ・オプション引数を指定必須にする
オプション引数を必ず指定されるようにし, 指定されていないときにエラーを出したいときは, add_argumentのrequiredをTrueにする(デフォルトはFalse)
```python: test.py
parser = argparse.ArgumentParser()
parser.add_argument("--option1", required=True)
arg = parser.parse_args()
print(arg.option1)
```
```
# コマンドライン
$ python test.py

# 実行結果
usage: test.py [-h] --option1 OPTION1
test.py: error: the following arguments are required: --option1
```