# google workspaceを活用したデータ管理
210922 Mizuno T  
大学のg.eccアカウントで使用可能なgoogle workspaceを活用してデータのバックアップや管理体制を整える.  
windows向け  
大まかには以下の流れ  
1. google workspaceの設定  
2. ディレクトリの準備  
3. バックアップの設定  
4. ディレクトリ構造の理解・使い方  

******
# 1. Google workspaceの設定
以下を参照して大学で購入しているGoogle workspaceに登録する。  
[参照先](https://www.ecc.u-tokyo.ac.jp/files/ECCS_Cloud_Mail_User_Manual.pdf)
* 登録してから使用可能になるまでに若干ラグがある。  
* パスワードの再設定が年に一回程度のペースで求められるので注意。  


******
# 2. バックアップの設定
google workspaceを使ってデータを自動でバックアップする.  
以前は二種類あったが, 2021年8月現在はパソコン版google driveに統一されたので, google driveを使用する.  

## 1. DL/インストール
適当なサイトを参照して導入する.  
[参照先](https://support.google.com/a/answer/7491144?hl=ja)

## 2. cacheの移動
google driveのGUIからできる (2021/9/22, Nemoto S).  
- Dドライブにキャッシュ保存用のフォルダを作る (ex. D:\DriveFS)  
- タスクトレイのgoogle driveアイコンをクリック  
- 右上の歯車をクリック  
- 設定をクリック  
- さらに右上の歯車をクリック  
- 「ローカルにキャッシュされたファイルのディレクトリ」を変更して上記作成したフォルダを指定する  
- google driveの再起動  
- 以上によりgoogle driveの実体をDドライブに変更できる (容量的に必須)  

## 3. 保存用ディレクトリの確認
水野が事前に共有ドライブを大学アカウントに用意している (用意されていない場合には水野に問い合わせ)  
googleドライブ内の共有ドライブにデータ保存用のディレクトリがあることを確認する (以下, 保存用ディレクトリとする).  
以下の命名規則となっている.  
``` {ラボへの入学年度}_{苗字}{名前の頭文字} ```  
例えば水野の場合は以下のようになる.  
``` 2008_MizunoT ```  
ディレクトリ内は以下のように配置となっている.  

    
    2008_MizunoT  
    ├─notebook  
    ├─slide  
    ├─paper  
    ├─discussion  
    ├─conference  
    ├─document  
    ├─datasource  
    ├─protocol  
    └─others  
    
[ここ](https://drive.google.com/drive/folders/1C9oUaMKPfdKbwiYTsJmTl3PcAiCbm3B2?usp=sharing)の2008_MizunoTを参照.  


## 4. シンボリックリンクによるユーザビリティ向上
共有ドライブ上に保存ディレクトリを作成することで、バックアップが容易になる。しかしGドライブ経由のパスは煩わしい('共有ドライブ'という日本語が入る点など)。そこで、共有ドライブ上にバックアップデータを蓄積しつつ、それらをDドライブにシンボリックリンクを通し、Dドライブ経由でアクセスできるようにする。因みにDドライブにGドライブの```ショートカット```を作成してもパスはGドライブのままなので、```シンボリックリンク```である点が肝要。

1. 管理者としてコマンドプロンプトを起動し、``` C:\WINDOWS\system32>mklink /D D:シンボル先 G:共有ドライブ\Year_Name ```  のようにコマンドを叩く。例えば、私の場合は、```C:\WINDOWS\system32>mklink /D D:GdriveSymbol G:共有ドライブ\2020_AzumaI```となり、```D:GdriveSymbol <<===>> G:共有ドライブ\2020_AzumaI のシンボリック リンクが作成されました```のようなメッセージが表示されたら完了。
2. こうすることで、```G:共有ドライブ\2020_AzumaI\notebook\data.txt```について```D:GdriveSymbol\notebook\data.txt```で参照することが可能になり、Dドライブからパスが取得可能になる。また共有ドライブ先でもシンボリックリンク先でもファイル操作はどちらも反映されるため便利。

- 日々の作業は保存用ディレクトリである```G:共有ドライブ\Year_Name```上で行う。上記によりここへのパスによるアクセスが楽になる。  
- この逆の操作である、Gドライブ上にDドライブのシンボリックリンクを通す操作はエラーが出力されて現状無理っぽい。
- cacheの移動でデフォルトのCドライブからDドライブに移行しないと容量の制限が厳しくなるので注意。
(2021/01/26 Azuma I)


## 5. バックアップの確認
1. 保存用ディレクトリ内でテキトーにファイルを一つ作成する  
2. クラウド上のgoogle driveを開き, 自身の名前の共有ドライブ内に作成したファイルが見えるかどうかを確認する  


******
# 3. ディレクトリ構造の理解・使い方
研究活動は基本的に上記で作成した保存用ディレクトリ下で行う.  
それぞれのフォルダは以下のように利用・管理する.  

* notebook: 試験の結果, summary. [共有ドライブmizuno-group内の#ResearchEnvironment](https://drive.google.com/drive/folders/1pIJ_-IpG7Hpjkjd3a-kLLSTXrwdX_UtG?usp=sharing)を参照する.   
各試験はdiscussionとは別でsummaryとしてまとめる.  

* slide: コロキウムやバイオセミナーのスライド等. 各回のフォルダーで管理.  
ex)  
2008_MizunoT  
├─slide  
│  ├─190512  
│  ├─190714  
  
* paper: 論文. 内容ごとに分ける. 自分がわかりやすい範囲の粒度でよい.  
ex)  
2008_MizunoT  
├─paper  
│  ├─CMap  
│  ├─batch  

* discussion: ディスカッション資料の保存. 回ごとにフォルダに分ける. 自分がわかりやすい範囲の粒度でスライドは分けてもよい.  
各試験のsummaryとは別  
ex)  
2008_MizunoT  
├─discussion  
│  ├─2020  
│  │  ├─201030  
│  │  │  ├─201030.pptx  

* conference: 学会関係. 学会ごとに分ける. 要旨やプログラムはもちろんのこと, 立替情報, 予約情報, eticketなどなどまとめておく.  
ex)  
2008_MizunoT  
├─conference  
│  ├─190728-31_ISSX2019    
│  ├─190621-22_ICCA-LRI  
  
* document: 学振等の書類関係.  
    
* datasource: DLしてlocal保存しているデータ. 加工済みのready-to-useなものとrawデータとを保存.  
ex)  
2008_MizunoT  
├─datasource  
│  ├─GEO  
│  │  ├─GSE69845  
│  │  ├─GSE62627  

* protocol: 実験プロトコールやdatasheetなど.  
  
* others: その他大学関係.  


******
# 実験ノート
* notebookディレクトリ内で階層的に管理する.  
* 日々の実験内容を漏らさず残すことと, それらのデータをまとめることとを分けて考える.  
* 詳細は[共有ドライブmizuno-group内の#ResearchEnvironment](https://drive.google.com/drive/folders/1pIJ_-IpG7Hpjkjd3a-kLLSTXrwdX_UtG?usp=sharing)を参照する.  
