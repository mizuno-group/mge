# unittestのハウツー
PyPI等, packageを外部に公開する際にはtestが必須.  
unittestを用いたpythonのpackageのtestに関する備忘録.  
windows10, 2020/7/11, python 3.6  

***
# <u>やり方</u>
以下の流れで実施する.  
1. 適切にディレクトリを構成する.  
1. test_.pyファイルを書く.  
1. ターミナル上でrunする. 


## ■ 1. ディレクトリ構成
ディレクトリ構成は一般に以下のようになる.  
    
```
    /MYPKG # 配布用パッケージフォルダ
    ├── mypkg # パッケージ本体
    │   ├── __init__.py
    │   ├── mod1.py
    │   └── mod2.py
    ├── tests # test用フォルダー
    │   ├── __init__.py
    │   ├── test_mod1.py
    │   └── test_mod2.py
    ├── .gitignore
    ├── LISENCE.txt
    ├── MANIFEST.in
    ├── README.md
    ├── REQUIREMENTS.txt
    └── setup.py

```
    
## ■ 2. testの記述
test_*.pyの形でmypkg中のmoduleのtestを記述していく.  
基本的に1 moduleにつき1 test_*.pyを用意していく.  

### 例1)
test内容を記述する.  
1. 実際に引数を与えて関数を実行するパート  
1. 期待される結果を記述するパート  
1. 実際と期待とを比較するパート  
に分かれる.  

assertXXXXのmethodは色々ある.  
だいたい想像できるものは実装されている印象.  

`asertEqual(a,b)`: `a==b`  
`assertTrue(X)`: `X is True`  
`assertIs(a,b)`: `a is b`  
`assertIsNone(X)`: `X is None`  
`assertIn(a,b)`: `a in b`

    
```python:test_mod1.py

def module1(self,a,b):
    return a + b

```
    
    
```python:test_mod1.py
from unittest import TestCase

from mypkg import mod1 # mypkgの部分は自分のパッケージ名に合わせて適宜変更

class TestMod1(TestCase): # TestCaseを継承させる必要がある
    def test_module1(self):
        ### 1. get actual data
        # コードをrunさせた結果を得る
        val1 = 5
        val2 = 2
        actual = mod1.module1(val1,val2)

        ### 2. define expected data
        # 想定される結果を書いておく
        expected = 7

        ### 3. compare the actual and the expected
        # 一致することを確かめる
        self.assertEqual(expected, actual)

```
    
    
### 例2)
複数の引数の組み合わせを試すときはsubTest methodが使える.  
subTest methodを使うことでtestを独立して行ってくれる.  
これによりfor文等で呼び出したときに一つでエラーが出て止まったり, エラーが回収できないといったことを回避できる.  

```python:test_mod2.py

def module2(a,b,method="subtract"):
    if method=="subtract":
        return a - b
    elif method=="multiply":
        return a * b
    else:
        raise ValueError("!! Wrong method !!")

```

```python:test_mod2.py
from unittest import TestCase

from mypkg import mod2 # mypkgの部分は自分のパッケージ名に合わせて適宜変更
    
class TestMod2(TestCase): # TestCaseを継承させる必要がある
    def test_module2(self):
        ### test patternを書きだす
        test_patterns = [
            (5,2,"subtract",3), # (引数1, 引数2, 引数3, 期待される結果)
            (5,2,"multiply",10)
            ]
    
        ### for文で回す
        for ta,tb,tmethod,expected in test_patterns:
            with self.subTest(a=ta,b=tb,method=tmethod): # 引数を入れる
                self.assertEqual(mod2.module2(ta,tb,tmethod),expected) # assertのmethod

```

## ■ 3. testの実行
ターミナルからtestを実行する.  
test_*.pyをまとめたtestsフォルダの1階層上 (普通は配布用のパッケージフォルダ) に移動してから実行すること.  
それ以外でももちろんできるが, 以下の方法で実行する場合にはそのように移動しないとpathが通らない.  
testsとmypkgのディレクトリが違うので, mypkgからtestしたいmoduleを呼び出すところでハマる人が世の中では多い模様.  

1. 仮想環境起動  
`conda activate [使いたい環境名]`    

1. 配布用パッケージを置いているディレクトリに移動  
`cd [配布用パッケージのpath]`

1. testを実行  
`python -m unittest discover tests`
    * testsの部分はtest用のフォルダー名. 慣例的に大体testsだから変える必要なかろうが.  

***
# unittestのハウツー2
unittestを用いたpythonのpackageのtestに関する備忘録.  
deproの公開に際し学んだこと備忘録
windows10, 2020/8/14, python 3.7  

## ■ 1. ディレクトリ構成
ディレクトリ構成は一般に以下のようになる.  
    
```
    /MYPKG # 配布用パッケージフォルダ
    ├── mypkg # パッケージ本体
    │   ├── __init__.py
    │   ├── mod1.py
    │   └── mod2.py
    ├── tests # test用フォルダー
    │   ├── __init__.py
    │   ├── test_mod1.py
    │   └── test_mod2.py
    ├── .gitignore
    ├── LISENCE.txt
    ├── MANIFEST.in
    ├── README.md
    ├── REQUIREMENTS.txt
    └── setup.py

```


## ■ 2. testの記述
ポイントは以下.  
* test_*.pyの形でmypkg中のmoduleのtestを記述.  
* 1 moduleにつき1 test_*.pyを用意.  
* 条件はsubtestを使ってループ.  
* assertEqualとassertRaisesをif文で使い分ければ大体いける.  
* setUpClassはクラス変数を使って全体で使い回すものを定義.  
* setUpは各testでの初期化担当と思う.  

### ざっくりした構成
1. 全体で使い回す用のデータをsetUpClassで定義  
1. 各testの初期化処理をsetUpで定義  
1. (必要があれば) testの判定用のwrapper関数を準備  
1. testで評価したい引数, エラー判定のflag, 期待される結果のパターンを定義  
1. パターン中のflagを使ってassertEqualとassertRaisesを分岐  

### 具体的なコード
```
    import unittest # 必須
    import pandas as pd # その他使いそうな連中  
    import numpy as np
    import os
    import sys
    import math

    from MYPKG.mypkg import Mypkg # 自分のパッケージの読み込み

    BASEPATH = os.path.dirname(os.path.abspath(__file__)) # データ読み込むときとかに使う

    class SampleTest(unittest.TestCase):
        SETUP = None # class変数の定義, 全体で使い回す子

        # called when test class initialization
        # 使い回し用に読み込んでおきたいもの
        @classmethod
        def setUpClass(cls):
            print('****** setUpClass method is called. ******')
            cls.SETUP = pd.DataFrame(hogehoge)

        # called when test class end
        @classmethod
        def tearDownClass(cls):
            print('****** setDownClass method is called. ******')

        # called when a test method runs
        # testごと開始時に呼び込みたいもの
        def setUp(self):
            self.smpl = Depro() # initializationは必須

        # called when a test method ends
        # testごと終了時に呼び込みたいもの
        def tearDown(self):
            pass # あんまりないか

        # wrapper
        # test用のラッパー関数, 適宜作成
        def wrapper(self,X):
            if type(X)!=np.ndarray:
                return False
            elif X.shape[0]==0:
                return False
            else:
                judge = math.isnan(X[0,0])
                return not judge

        # test本番
        def test_preprocess(self):
            # prepare test patterns
            test_patterns = [
                (True,0.05,True,False,True), # (arg1, arg2, ..., flag, expected result)
                (False,0.05,True,False,True), # (arg1, arg2, ..., flag, expected result)
                (True,0.05,False,False,True), # (arg1, arg2, ..., flag, expected result)
                (False,0.05,False,False,True), # (arg1, arg2, ..., flag, expected result)
                (True,0.2,True,False,True) # (arg1, arg2, ..., flag, expected result)
                ]

            ### loop for sweeping all conditions
            self.smpl.set_data(SampleTest.SETUP) # class変数へのアクセスに注意
            for tmirror,talpha,tsphere,flag,exp in test_patterns: # 上述のパターン
                with self.subTest(mirror=tmirror,alpha=talpha,sphere=tsphere): # 関数に入れるもののみ
                    print(tmirror,talpha,tsphere,flag,exp) # プリントしとくとわかりやすい気がする
                    if flag:
                        with self.assertRaises(exp): # raiseするエラーを引数に入れる
                            self.smpl.preprocess(mirror=tmirror,alpha=talpha,sphere=tsphere) # エラーが予期される処理
                    else:
                        self.smpl.preprocess(mirror=tmirror,alpha=talpha,sphere=tsphere)
                        self.assertEqual(self.wrapper(self.smpl.get_processed()["X"]),exp)
```


***
# <u>オマケ：ターミナルからの実行について</u>
ターミナルからの実行についていくらか.  

## ■知っておくべきこと1: ファイルの場所に移動してから実行
うちの班ではanacondaで構築した仮想環境中でのpython実行が多い.  
ターミナル (=anaconda prompt) でpythonを実行する際の手順を示す.  
要はファイルの場所に移動することが肝要.  

1. いつもどおり仮想環境XXXXを起動する.  
`conda activate XXXX`
    * XXXXは使いたい仮想環境名  

1. runしたい.pyファイルを置いてあるディレクトリYYYYに移動.  
`cd YYYY`
    * YYYYは当該ディレクトリのパス  

1. ファイル名を指定して実行.  
`python ZZZZ.py`
    * ZZZZ.pyは実行したいファイル


## ■知っておくべきこと2: 移動先ディレクトリにはpathが通っている
例えば以下のような構成を持つ`C\Users\XXXX\tests`に移動しているとき, runner.pyからちゃんとtest_mod1を呼び出せる.  

```
    tests
    ├── __init__.py
    ├── runner.py
    ├── test_mod1.py
    ├── test_mod2.py
```


```python:runner.py
import test_mod1
# (略)
```

## ■知っておくべきこと3: if __name__ == '__main__'の使い方
ターミナルから呼び出したときrunしたい処理は以下のように書く.  

```python
    if __name__ == '__main__':
        # ターミナルから呼び出したときにrunしたい処理
```

ターミナルからの実行の際には__name__変数 (XXXX.pyのXXXX) が__main__変数と一致することを利用している.  
