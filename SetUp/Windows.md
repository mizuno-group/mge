# 231214 Windowsのセットアップについて  
　先日行ったセットアップの際のピットフォールの共有です。  

## １インストールメディアの作成    
 U-tokyoのマイクロソフトアカウントでは、現在windows10、windows11のインストールを行うことができます。  
 ただし、どちらか一方をダウンロードすると、もう一方をダウンロードできない。  
 [こちらのサイト](https://utokyo.onthehub.com/WebStore/ProductsByMajorVersionList.aspx?cmi_cs=1&cmi_mnuMain=f4b2ea63-9ba9-e511-9413-b8ca3a5db7a1)からダウンロードできる。  

 インストールメディアの作成の際には、[rufus](https://www.diskpart.com/jp/windows-11/rufus-windows-11-3320-tc.html)を使用する。  
 使用の際には、isoファイルのダウンロードは手元のPCに、インストールメディアはUSBにダウンロードするように設定する。  
 使用方法の詳細は、[このサイト](https://original-game.com/how-to-use-rufus/)を参考にすること。  

  また、USBのフォーマットの確認を忘れないこと。(Fat32ではおそらくダウンロードできない。NTFSにすること。)

## ２BIOSからのインストール
  基本的にはUbuntuのセットアップと同様。
  boot先をUSBにする。secure bootは変更しない。  
  だけである。

　boot用のcドライブで実行すること。

　注意が必要なのは、その後で、プロダクトキーの入力が求められる。  
  これは、[このサイト](https://utcode.net/articles/windows-home-to-education/)をもとに確認すること。  
  ただし、プロダクトキーの反映は遅いため、プロダクトキーを使用せずに立ち上げて、その後入力する方がよい。
