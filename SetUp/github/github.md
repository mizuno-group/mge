github導入 (Mizuno T)  
windows向け  
[参考になるサイト](https://xn--v8jtdudb.com/%E3%81%AD%E3%81%93/web/%E3%83%89%E7%B4%A0%E4%BA%BA%E3%81%AB%E3%82%88%E3%82%8BGitHub%E4%B8%8A%E3%81%A7%E3%81%AE%E3%83%95%E3%82%A9%E3%83%BC%E3%82%AF%E3%81%A8%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E4%BF%AE%E6%AD%A3%E3%81%A8%E3%83%97%E3%83%AB%E3%83%AA%E3%82%AF%E3%82%A8%E3%82%B9%E3%83%88%E3%81%BE%E3%81%A7%E3%81%AE%E8%A6%9A%E6%9B%B])

******
# よくやる流れ
* 基本的に共有しているリポジトリのmasterはいじらない.  
* 自分の名前のmainブランチとdevelopブランチを作り, developで作業して, mainに反映していく.  
* ディスカッションを経て確定版となった場合, masterへとmergeして班全員で共有する.  
* 自分のバージョン管理という点でmainとdevelopを分けると便利だが, 更新するだけならいきなりmainで作業すればOK. 単に後戻りしやすいというだけ.  
1. 自分の名前のmainブランチを作っておく.
`git branch miz`
2. ローカルで作業し, .pyの編集などを行う (test.pyとする).
* test.pyは自身のローカルの当該リポジトリのフォルダに置く. というか基本その場所のtest.pyを直接編集する. 
* 別の場所で編集した場合にはこちらに統合する.  
3. 編集したものを自身のdevelopブランチに上げる.
* developブランチを作成していない場合は, checkoutに-bオプションをつける

    ```
    git checkout miz_dev
    git add test.py
    git commit -m "modification"
    git push origin miz_dev
    ```
4. 編集したものに満足がいったときはmainブランチに統合する.

    ```
    git checkout miz
    git branch
    git merge miz_dev
    git push origin mizuno
    ```

# よく使うコマンド
## cmd開いて作業する

    windows + x  
    r  
    cmd  
    cd github  
    cd [作業するローカルリポジトリ]  

## ブランチの作成・移動

    git branch [ブランチ名]
    git checkout [ブランチ名]

or
`git checkout -b [ブランチ名]`  

## ローカルでの作業をリモートへ反映  

    git add [ファイル名]
    git status
    git commit -m "[反映内容に関するコメント]"
    git push origin [ブランチ名]

## 自分のメインのブランチ(mizuno)と作業中のブランチ(develop)の統合  

    git checkout mizuno
    git branch
    git merge develop
    git push origin mizuno

## 不要になったブランチの削除  
1. github上でごみ箱ボタンを押してリモートのローカルブランチを削除する.
2. ローカルブランチの削除.
`git branch -d [ブランチ名]`
* 特に反映する気がなかったものでmergeされてないけど!ってエラーが出る場合は-Dオプションを使う.  
3. リモート追跡ブランチの削除.
`git branch --remote -d origin/[ブランチ名]`

## リモートの情報をローカルへと反映  

    git checkout [local branch name]
    git pull [リモートリポジトリ名, 大体origin] [該当ブランチ名]

or  

    git checkout [local branch name]
    git fetch [リモートリポジトリ名, 大体origin]
    git merge [リモートリポジトリ名, 大体origin]/[該当ブランチ名]

* fetch/mergeの際には, リポートリポジトリ名と該当ブランチ名の間に/を入れることを忘れない.  
* ローカルにブランチがない際には, `checkout`に`-b`オプションを付ける.  

******
# 設定
以下だとか適当なwebサイトを参照する. 
[参照先](https://qiita.com/Kenta-Okuda/items/c3dcd60a80a82147e1bf)

## 1. インストール
以下のオプションを選ぶ. 他は割とどうでもよい. 
* Use Git from the Windows Command Prompt
* Checkout as-is, commit as-is
* Use MinTTY (the default terminal of MSYS2)
以下は現状だと外しておいた方がよいかも. 
* Enable file system caching

## 2. ユーザー設定
以下を入力

    git config --global user.name "mizuno group"
    git config --global user.email "tadahaya@g.ecc.u-tokyo.ac.jp"

* 大学のPCで行う作業はこれで統一する. 

## 3. エディタの設定
`git config --global core.editor 'vim -c "set fenc=utf-8"'`

## 4. カラーの設定

    git config --global color.diff auto
    git config --global color.status auto
    git config --global color.branch auto


******
# 基本操作

## 1. リポジトリ作成
windowsの場合, コマンドプロンプトcmdをデフォにする. 

### 1-1. Cドライブ直下にgithubディレクトリを作成する. 
* 例) C:\Users\tadahaya\github

### 1-2. githubフォルダ内にリポジトリごとのディレクトリを作成し, 関連する.pyファイルを置いておく
* 例) C:\Users\tadahaya\github\test\test.py

### 1-3. cmd上で当該ディレクトリに移動
`cd C:\Users\tadahaya\github\network`
`cd /`　→　ルートへ移動
`cd ../`　→　一つ上のディレクトリへ移動

### 1-4. (初回のみ)gitの初期化. 対象ディレクトリに.gitディレクトリを作成することと同義
`git init`
* 当該リポジトリの初回, ないし初期化したいときのみ行う. 

***
## 2. ブランチ
別々の作業を並行して行うために利用. 
基本的にmasterは触らず, branchで作業する. 
ローカルで作業していたブランチをpushすると, リモートでもブランチの方に反映される. 

### 2-1. ブランチ作成
`git branch [branch name]`
単にbranchコマンドを実行すると, ブランチの一覧を取得できる. *付きが現在のブランチ. 
* このコマンドでローカルにブランチができる. リモートはこの段階では変わらない. 


### 2-2. ブランチ切り替え
以下のコマンドでブランチを切り替えることで, 切り替えた先のブランチへとコミットできるようになる. 
`git checkout [branch name]`
* `git checkout -b [branch name]` -bオプションにより, 新しいブランチの作成と同時に移動ができる


### 2-3. ブランチの削除
ブランチコマンドに-dオプションを付けると削除になる. 
`git branch -d [branch name]`


### 2-4. マージ
現在のブランチに対して, 他のブランチで行った変更を取り込むためのもの. 
順序に注意. 
`git checkout [branch name]`
`git merge [another branch name]` # [branch name]に対して[another branch name]ブランチをマージ


### 2-5. ブランチ名の変更
`git branch -m [current branch name] [new branch name]`
* 作業中のブランチであれば-mオプションで新ブランチ名を指定すればOK


***
## 3. add
編集したファイルをステージ領域にアップする. 
* ステージ領域：　コミットする前の一時的な保管場所
* ステージング: addの操作
以下のコマンドで可. 
`git add "test.py"`
ディレクトリ中全てのファイルの場合には, 
`git add .`


***
## 4. commit
ステージ領域にあるファイルをリポジトリに記録する. 
前回のコミット時から今回のコミット時までの差分のファイル(＝コミット)が作成される. 
ローカルリポジトリのみの操作, 次のpushをするまでリモートリポジトリは変わらない. 
以下のコマンドで可. 
`git commit -m "commit message"`
* commit messageには変更の内容を入れる. 
-mで指定しない場合にはvimを使って長めの説明を書ける. 
`git commit`
vimに移るので, 以下の区分に分けてコメントを入れる. 
* add : ファイルの追加
* fix : バグ修正
* hotfix : クリティカル(致命的)なバグの修正
* update : 機能修正（バグではない）
* change : 仕様変更
* clean : 整理（リファクタリングなど）
* remove : ファイルの削除
* upgrade : バージョンアップ
コメントを入れ終えたらescでモードを切り替えた後に, `:wq`でvimを抜け出す. 


***
## 5. push
リモートリポジトリにローカルリポジトリの情報を共有する. 
ローカルの時と同じく, まずはaddでステージングし, その後にpushで変更を反映する. 
### 5-1. remote add
以下のコマンドで可. 
`git remote add origin https://github.com/mizuno-group0/test.git`
* testの部分はリポジトリ名
`remote add XXXX YYYY`という構造になっており, XXXXというリモートリポジトリを作成している感じで, 通例originが使われる.  
originリモートリポジトリの別名と思っておけばOK.  

### 5-2. push
ローカルブランチの情報をリモートに反映するコマンド.  
以下のコマンドで可. 
`git push -u origin [local branch name]` #[local branch name]はローカルのブランチ名  
* 最初はユーザー名, パスワードを聞かれる. 
* ユーザー名) mizuno-group0
* パス) haya[一研の内線番号]
* -uオプションは, 上流ブランチ(更新を取り込む先のリモートのブランチ)の設定用で, 一度設定してしまえば以降は不要. 
* リモートにある[local branch name]と同じ名前のブランチに対して反映する.  

### 5-3. addの取り消し
`git remote -v`で現状のリポジトリを確認し, 
`git remote rm origin`でoriginを削除できる. 
その後もう一度addからやり直せばよい. 


***
## 6. プル
最新のリモートリポジトリを取得するためのコマンド. 

    git checkout master #masterブランチに移動
    git pull origin master #masterブランチにリモートリポジトリのmasterブランチをマージ

* 引数無しの場合は, カレントブランチのみが対象となる.  

***
## 7. クローン
既存のリモートリポジトリをローカルに落とすために使うコマンド. 
`git clone https://github.com/'ユーザID リポジトリ名'.git 'クローン先のディレクトリ名'`  
特定のブランチをローカルにクローンする場合は-bオプションを使う.  
`git clone -b [ブランチ名] https://github.com/'ユーザID リポジトリ名'.git 'クローン先のディレクトリ名'`  

******
# その他の操作やtips
***
## ◆ファイルの削除
リモートリポジトリのファイル削除する際には, 該当のgitに入っている状態で以下のコマンド. 

    git rm [local file name] #ローカルから[local file name]が消える
    git commit -m 'remove [local file name]' #リモートへ削除をコミット, コメントはもちろんなんでもいい.
    git push origin master #リモートで削除が反映


***
## ◆remote
リモートリポジトリのやりとりに使用する. 

### remote add
`remote add XXXX https://github~`でXXXXという名前のリモートリポジトリを当該urlのリポジトリに作成できる. 
ただしgithubのweb上では見えてこず, `remote -v`で可視化できる. 
このときXXXXにpushすると, 当該urlのリポジトリに変更が反映される. 
つまるところurlが肝要となっており, 普段は`git push origin YYYY`が適当だろう(YYYY:ブランチ名). 

### remote rm
`remote rm XXXX`でXXXXという名前のリモートリポジトリを削除できる. 
ただしgithubのweb上では見えてこず, `remote -v`で可視化できる. 


***
## ◆ブランチ削除の色々
### マージされているローカルブランチXXXXの削除
`git branch -d XXXX`

### マージされていないローカルブランチXXXXの削除
`git branch -D XXXX`
* -dだとmergeしていないよって怒られる. 

### リモートブランチXXXXの削除
リモートリポジトリがoriginであるとき,

    git push --delete origin XXXX #まず削除して
    git fetch origin --prune #それを反映する感じ.

あるいは以下も可.

    git push origin :XXXX
    git fetch origin --prune


## ◆リモート追跡ブランチ
厳密には, 
  
ローカルリポジトリ    
├─ローカルブランチA  
└─リモート追跡ブランチB  
  
リモートリポジトリ    
└─(リモートリポジトリにおける)ローカルブランチC  
  
というような構造になっている. 以下のHPが参考になる.  
[参照先](https://qiita.com/forest1/items/db5ac003d310449743ca)

### ローカルブランチ(A)
自分のマシン上のブランチ.  

### リモート追跡ブランチ(B)
リモートリポジトリのローカルブランチCを自身のローカルへと保持したブランチ.  
fetchやpullを実行することで初めて反映される.  
コマンド上では, `origin/master`や`origin/develop`として表示される.  

### (リモートリポジトリにおける)ローカルブランチ(C)
web上のブランチ.  
リモート追跡ブランチを通じてしか知り得ない.  
  
以上を踏まえた上でコマンドを再解釈すると, 
### push
AがB, Cに反映される.  

### fetch
Cの情報をBにのみ反映する.  

### pull
Cの情報をB, Aに両方に反映する.  
* 厳密にはfetch + merge, fetchした後にカレントブランチに対して対応するリモート追跡ブランチをマージする.  
