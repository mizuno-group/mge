# 水野班でのgithub運用について
普段の研究活動は[mizuno-group](https://github.com/mizuno-group)のorganization内で行う。  
一方, 各人の貢献を卒業後もわかりやすく残すため, 「organizationでリポジトリを作り, これをforkしたリポジトリを各自の個人アカウントで扱う」建付けをとる。  


### <u>**個人githubアカウントの作成とorganizationへの所属**</u>
1. 個人のgithubアカウントをテキトウに作成する。いずれ揮発する大学のアカウントではなく, gmailなど卒業後も使い続けるアカウントで作成する。  
2. 水野に作成したアカウントのgithubユーザー名か登録emailアドレスを連絡し, organizationへ登録する。  


### <u>**水野班リポジトリの準備**</u>
1. [mizuno-group](https://github.com/mizuno-group)にリポジトリを作成する。（main）  
2. 自身が改変するブランチを作成する。（devなど）  
3. mainブランチに対してprotection ruleを追加する。基本はデフォルトの```Require a pull request before merging```で```Require approvals (n=1)```を設定すれば良いか。  


### <u>**個人リポジトリにフォークする**</u>
1. 上記の自身が改変するブランチ（dev）をForkする。Fork先のownerには自身のアカウントを指定する。  
2. Fork先の個人リポジトリでは基本的にmainブランチで作業する。  


### <u>**個人main→水野班devにmergeして芝を生やす**</u>
1. 個人リポジトリのbranchを選択する欄の下に```This branch is n commits ahead of mizuno-group:main.```と表示があることを確認。  
2. ```n commits ahead```をクリックすると差分を確認できる。  
3. 個人のmainブランチを水野班のdevブランチに反映する設定。```base repository: mizuno-group/XXX``` ```base: dev``` ＜== ```head repository: mizuno-group/XXX``` ```base: main```  
4. create pull request  
5. conflictsが発生しないことを確認し、```merge pull request```からの```confirm merge```。  

上記は個人が独立して実行可能である。Fork元のdevにmergeすることでようやく芝が生える。  
※ [芝を生やす](https://qiita.com/sta/items/2c1f0252a6a9ce5e2087)とは。


### <u>**水野班dev→水野班mainにmerge**</u>
1. 水野班のdevブランチに移動し、```n commits ahead```をクリックして差分を確認。  
2. ```base: main``` ＜== ```compare: dev```の設定を確認。  
3. ```create pull request```  
4. おそらく```✖ Review required```と```✖ Merging is blocked```とエラーが表示される。  
5. 第三者（基本は水野先生）がpull requestを確認し、承認することでmergeが完了する。  


***
### **運用方針変更の意義**
- 個人の研究への貢献を可視化する。  
- 開発段階から研究内容を積極的に対外的に発信する。  

### **更新情報**
- 230507 [grooby-phazuma](https://github.com/groovy-phazuma), [tadahayamiz](https://github.com/tadahayamiz)  
