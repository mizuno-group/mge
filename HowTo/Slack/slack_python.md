# SlackにPythonを使って通知を飛ばす

https://qiita.com/shtnkgm/items/4f0e4dcbb9eb52fdf316

非常に簡便に実装できるので、長い計算をしていて途中でエラーが出ていないか監視したり、途中経過を観察するのに使える。

## Incoming Webhookの設定

1. Appで「アプリを追加する」をクリックする。
2. 「Incoming Webhook」と検索すると出てくるので、「追加」をクリック。
3. 「Slackに追加」をクリック。
4. 「チャンネルを選択」の部分をクリックする。するとチャンネルが選択できるようになる。特に複数人での監視が必要でなければ自分の名前のチャンネルを選択して、「Incoming Webhook インテグレーションの追加」をクリック。（余談だがこのあたりの設定は実はPython側で適宜書き換えることができる）
5. Webhook URLをどこかにメモっておく。名前やアイコンなどもカスタマイズできるが、基本的に設定はデフォルトのままでもよい。

## Pythonでの通知の仕方

- requestsを使う方法（pipでもcondaでも）
- slackwebを使う方法（pip環境）

上記の２つがあるが、いずれも簡単。汎用性があるのでrequests推奨。

### requests

```
$ conda install requests
```

もしくは

```
$ pip install requests
```

コード

```
import requests

url = "出てきたURL"
payload = {'text':'送りたい内容'}
r = requests.post(url, json=payload)
```

### slackweb

```
$ pip install slackweb
```

コード

```
import slackweb

slack = slackweb.Slack(url="出てきたURL")
slack.notify(text="送りたい内容")
```

### 他の手段

ただ単にPOSTメソッドによりHTTPS通信でtextを送りつけているだけなので、同じことをするのであればcurlを使ったり他の方法でもできる。

```
$ curl -X POST --data-urlencode "payload={\"channel\": \"送りたいチャンネル\", \"username\": \"つけたいユーザー名\", \"text\": \"送りたい内容\", \"icon_emoji\": \":ghost:\"}" 出てきたURL
```