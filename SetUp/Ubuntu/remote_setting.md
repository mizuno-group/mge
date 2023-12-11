# Secureなremote設定

Client PC(C)→踏み台server(S1)→ラボ内の計算機server(S2)

## UFWの設定

S2のUFWについて設定を行う。

```
$ sudo ufw reset
```

このコマンドでこれまでのルールをリセット。

```
$ sudo ufw default deny
```

何もルールがない状態ではアクセス拒否する設定。通常の状態であればデフォルトでdenyになっているが、念のため設定しておく。

```
$ sudo ufw limit from [IP address] to any port [ポート番号]
```

これにより、ルールを追加する。ポート番号は採用しているSSHのポート番号。IP addressはS1のIP address。このタイミングで班員全員のIP addressをいれておく。

```
$ sudo ufw enable
```

で有効化。

