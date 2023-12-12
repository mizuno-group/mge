# Ubuntuのセキュリティ

## ufw

Ubuntuのファイアウォールはufwを通じて操作する。ufwはiptableを簡易的に操作できるようにしたものである。

[参考・簡易版](https://qiita.com/RyoMa_0923/items/681f86196997bea236f0)  
[参考・詳細版](https://www.gadgets-today.net/?p=4754)  

を参考に

### インストール

```
$ sudo apt -y install ufw
```

### デフォルトのポリシーをdenyにする

```
$ sudo ufw default deny
```

元からdenyなので不要らしい。ただ、デフォルト設定が不変なものなのかわからないので念のため実行しておく。

### 特定ポートへのアクセスを許可

```
$ sudo ufw allow to any port [SSH port]
```

[SSH port]部分は自分の選んだport番号

これでルールが追加されるが、さらにlimitでブルートフォースアタック対策を行う。

```
$ sudo ufw limit [SSH port]
```

これにより、30秒間に6回指定のポートにアクセスしてきたIPの接続を一定時間拒否する。

また、特定のIPアドレスからの接続のみ許可する場合は、

```
$ sudo ufw allow from [IP address] to any port [SSH port]
```

### 起動

```
$ sudo ufw enable
```

動作確認は

```
$ sudo ufw status

状態: アクティブ

To                         Action      From
--                         ------      ----
[SSH port]                LIMIT       Anywhere

```

でできる。ここで、非アクティブと表示されたらうまく起動できてない。

逆に無効化するには

```
$ sudo ufw disable
```

コマンドを使う。  


### 既にあるルールの削除

```
$ sudo ufw delete [削除したいルールの番号]
```

ルール番号は、

```
$ sudo ufw status numbered
```

で確認できる。
