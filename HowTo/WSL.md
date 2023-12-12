# WSL (Windows Subsystem for Linux)について

Windowsで簡単に使えるLinux環境

うちのラボでLinuxを使いたいというときには次の選択肢がある

- Linuxマシンを使う
- Dual boot
- Virtual Box
- WSL

上に行くほど、マシンのリソースがLinuxに必要で、導入がめんどくさい（そのかわり、RAMなどを十分に使えるようになり性能はよい）。

手元で、マシンパワーはそんなに要らないけど、Linux環境ではないと実行できないことを試したいというときにはWSLを導入するのがおすすめである。

## 導入方法

https://qiita.com/Aruneko/items/c79810b0b015bebf30bb

上記を参考にUbuntuを導入。

1. スタートボタンを右クリックして、アプリと機能をクリック
2. 右上にあるプログラムと機能をクリック
3. 左側の一覧から、Windowsの機能の有効化または無効化をクリック
4. Windows Subsystem for Linux (Beta)を探し、チェックを入れる
5. 再起動
6. Microsoft Storeを起動
7. 検索窓からUbuntuを検索
8．出てきたUbuntuを入手し、起動
9. ユーザー名とパスワードを設定
10. リポジトリを以下のコマンドで変更する。（アプリなどをダウンロードするときに、主にダウンロードする先のサーバーの物理的な位置を日本に変更する、こうしないと通信速度が遅い）

```
sudo sed -i -e 's%http://.*.ubuntu.com%http://ftp.jaist.ac.jp/pub/Linux%g' /etc/apt/sources.list
```

windowsのCドライブやDドライブは/mnt/c、/mnt/dというディレクトリに存在。
