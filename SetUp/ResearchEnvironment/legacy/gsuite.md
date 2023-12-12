GSuiteの活用 (Mizuno T)  
windows向け  

******
# GSuiteの設定
以下を参照して大学で購入しているGSuiteに登録する.  
[参照先](https://www.ecc.u-tokyo.ac.jp/files/ECCS_Cloud_Mail_User_Manual.pdf)
* 登録してから使用可能になるまでに若干ラグがある.  
* パスワードの再設定が年に一回程度のペースで求められるので注意.  

******
# PC内のフォルダ設定
Dドライブなど**ストレージHDD**に以下を作成する.  
デスクトップ上にショートカットかsymbolic linkを作成しておくと楽.  
親フォルダ名は, ラボへの入学年度+名前にする.  
ex) 2008MizunoT

2008MizunoT  
├─notebook  
├─slide  
├─paper  
├─discussion  
├─conference  
├─document  
├─datasource  
├─protocol  
└─others  

それぞれ以下のように管理する.  
* notebook: 試験の結果, summary. [共有ドライブmizuno-group内の#ResearchEnvironment](https://drive.google.com/drive/folders/1pIJ_-IpG7Hpjkjd3a-kLLSTXrwdX_UtG?usp=sharing)を参照する.   
* slide: コロキウムやバイオセミナーのスライド等. 各回のフォルダーで管理.  
ex)  
2008MizunoT  
├─slide  
│  ├─190512  
│  ├─190714  
  
* paper: 論文. 内容ごとに分ける. 自分がわかりやすい範囲の粒度でよい.  
ex)  
2008MizunoT  
├─paper  
│  ├─CMap  
│  ├─batch  

* discussion: ディスカッション資料の保存. 回ごとにフォルダに分ける. 自分がわかりやすい範囲の粒度でスライドは分けてもよい.  
ex)  
2008MizunoT  
├─discussion  
│  ├─2020  
│  │  ├─201030  
│  │  │  ├─201030.pptx  

* conference: 学会関係. 学会ごとに分ける. 要旨やプログラムはもちろんのこと, 立替情報, 予約情報, eticketなどなどまとめておく.  
ex)  
2008MizunoT  
├─conference  
│  ├─190728-31_ISSX2019    
│  ├─190621-22_ICCA-LRI  
  
* document: 学振等の書類関係.  
    
* datasource: DLしてlocal保存しているデータ. 加工済みのready-to-useなものとrawデータとを保存. 基本的にここのデータには触らず, dryフォルダに移して使用する.  
ex)  
2008MizunoT  
├─datasource  
│  ├─GEO  
│  │  ├─GSE69845  
│  │  ├─GSE62627  

* protocol: 実験プロトコールやdatasheetなど.  
  
* others: その他大学関係.  

******
# バックアップ関係
Gsuiteを使い, PC中のデータを自動でバックアップする.  
2019年12月現在は, "バックアップと同期", "ドライブファイルストリーム"の二種類が存在する.  
前者はローカルとの同期, 後者はストリームでgoogle drive上のものを利用する.  
一般には後者がGsuiteに適しているとのことだが, 速度面など不安な箇所もあるため, 現状は"バックアップと同期"をメインにする.  

## 1. DL/インストール
適当なサイトを参照して導入する.  
[参照先](https://blog.formzu.com/google_backup_and_sync)

## 2. 設定
1. 大学のGsuiteアカウントでログインする.  
2. PC上からgoogleドライブへバックアップ/同期するフォルダとして, D:\2008MizunoTとC:\Users\tadahaya\githubを指定する.  
3. googleドライブのマイドライブからPCへの同期はOFFにする.  
4. googleドライブ上で`tadahaya@g.ecc.u-tokyo.ac.jp`と共有する.  

## 卒業直前 (超重要)  
### 1. `tadahaya@g.ecc.u-tokyo.ac.jp`との共有ドライブを作成する  
上記で設定する共有アイテムとは異なる, ここの領域は卒業後も残る. 
上記は卒業して学生側のアカウントが消えると消えてしまうので注意.  
### 2. 自身のデータフォルダを上記共有ドライブにアップロードする
データフォルダ：ex. 2008MizunoT  

******
# 実験ノート
* notebookディレクトリ内で階層的に管理する.  
* 日々の実験内容を漏らさず残すことと, それらのデータをまとめることとを分けて考える.  
* 詳細は[共有ドライブmizuno-group内の#ResearchEnvironment](https://drive.google.com/drive/folders/1pIJ_-IpG7Hpjkjd3a-kLLSTXrwdX_UtG?usp=sharing)を参照する.  

## 卒業直前 (超重要)  
卒業するとアクセスできなくなるため.  
### 1. 全てのnotebookをpdf (or zip) でエクスポートする  
### 2. エクスポートしたものを`tadahaya@g.ecc.u-tokyo.ac.jp`との共有ドライブにアップロードする
