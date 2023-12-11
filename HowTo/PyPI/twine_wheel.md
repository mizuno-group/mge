# PyPIに自作モジュールをアップロードする際にハマったことまとめ
色々ハマったのでまとめておく.  

***
# reStructured.txt render error
`HTTPError: 400 Client Error: The description failed to render in the default format of reStructuredText`  
がわかりづらかった.  
複数ピットフォールがある模様.  

### 1. twine, setuptools, wheelのバージョン  
まずこれらのバージョンが古いとmarkdownには対応していない, などがあるので最新版にする.  

### 2. LISENSE.txtなどの外部読み込み  
これにもろハマった.  
どうやらテキストとして読み込んだものをsetup内で指定しようとすると, それ以外の領域にも影響してしまうらしい (正直どう影響しているのかまではわかっていない).  
取り急ぎの対応策としては, 自分で書いたライセンスとかでなければ<u>シンプルに`license='MIT'`としておけばいい</u>.  
おそらくちゃんと解決策があるんだろうけども, 自作のライセンスの場合はそのファイルもパッケージ内に組み込んじゃうのがいいのかなぁ.  

### 3. long_description_content_type  
これはハマった訳ではないが, markdownの場合は明示しないとワークしないようなのでハマる人もいそう.  
markdownの場合は, `long_description_content_type="text/markdown"`と指定してあげましょう.  
rstならデフォ設定のようなのでOKっぽい.  

ちなみにトラブルシューティング方法としては,  
    
    # 失敗したbuild, dist, XXXX.egg-infoを削除
    # 何かしら対策を講じる
    python setup.py sdist bdist_wheel # 再度ビルド
    twine check dist/* # 内容確認
    
を地道に繰り返してた...二度とやりたくない.  
