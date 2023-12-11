# ディレクトリに対応して複数のgithubアカウントを切り替える方法
* 公開用アカウントとラボ内用アカウントの使い分けの際に必要になった.  
* configファイルを弄るだけなのですぐできる.  
* ただしremoteにアクセスする際はgit credential helperがいるのと, ユーザー指定をする必要がある.  
* 2020/7/18  
* [参照1](https://kakakakakku.hatenablog.com/entry/2019/11/06/114926)  
* [参照2](https://qiita.com/riverswon/items/f7e7174be15c5d7d520f)  
* [参照3](https://qiita.com/chatrate/items/106c8497e15be8b8cede)  

# 環境
* windows10, httpsでのみ検証.  
* gitのversionが2.1.4以上である必要がある (`includeIF`を使用するため)  
* git credential helperが入っている必要がある (インストール時注意)  

***
## 1. 別のディレクトリを準備する
だいたいは以下のようにuser直下がホームディレクトリのはず.  
    
    C:/Users/[username]/github
    ├── g1
    └── g2
    
ここに分ける用の別ディレクトリを用意する.  
        
    ~/github
    ├── g1
    └── g2
    ~/github_2nd # 分ける用ディレクトリ
    ├── g3
    └── g4
    
別ディレクトリをgit initしておく.  
    
    # cmdにて
    cd github_2nd
    git init
    
## 2. 別ディレクトリ用のconfigを準備する
適当なeditorを使って別ディレクトリのconfigを準備する.  
作成したらglobalの.gitconfigと同じところ (普通ならホームディレクトリ) に置く.  
    
    # ファイル名は.gitconfig_2ndとでもしておく, 何でもいい.  
    # 元々の.gitconfigをコピーして[user]部分のみの書き換えが楽ちん
    [user]
	name = username_2nd # 別ディレクトリで使うアカウントのuser名
	email = useremail_2nd@xxxx.com 別ディレクトリで使うアカウントのuser名
    :
    
## 3. globalのconfigを書き換える
.gitconfigを適当なeditorで開いて以下のように追記する.  
    
    [user]
    :
    # --- 追記箇所開始 --- 
    [includeIf "gitdir:~/github_2nd/"]
        path = ~/.gitconfig_2nd
    # --- 追記箇所終了 ---
    :
    
`includeIF`で条件付けできて, gitdirで指定したディレクトリにはpathで指定したconfigファイルを使うようにする感じ.  

## 4. 設定の確認
指定した別ディレクトリに移ってからconfig内容を確認して, 確かに変更されていればOK.  
    
    # cmdにて
    cd github_2nd
    git config user.name
    # username_2ndが返ってくるはず

設定終了, 便利ですね.  

***
# 実際に使い分ける際の注意点
## ユーザー指定してoriginを作る
上記設定をした後, 当該ディレクトリで作業して普通にプッシュしようとすると,  
	
	remote: Permission to mizuno-group/geneutil.git denied to mizuno-group0.
	fatal: unable to access 'https://github.com/mizuno-group/geneutil.git/': The requested URL returned error: 403
	
とPermissionエラーが出る.  
対策として,  
* ユーザーを指定してoriginを作成する  
* 403への対処にgit credential helperを使う  

必要がある模様.  
具体的には,  
1. git credential helperが入っていなければ導入する (``` git update-git-for-windows ```とかでできる)  
2. 当該ディレクトリで事前にgitを使ったことがある場合は, ```.git```自体を削除するか```git remote rm origin```でoriginを消す.  
3. ```git remote add origin  https://github.com/{sub group名}/XXXX.git```ではなく, ```git remote add origin https://{sub group名}@github.com/{sub group名}/XXXX.git```とする (ユーザー名を指定するやり方らしい)  
とすれば後はいつもどおりできる模様.  

3.の段階だかでgit credential helperによるブラウザでの認証が入るのでOKする.  

## ユーザー指定してpushする  
上記と同様に, pushの際にもユーザー指定がいる  
``` git push https://{sub group名}@github.com/{sub group名}/XXXX.git master```のような感じ.  
