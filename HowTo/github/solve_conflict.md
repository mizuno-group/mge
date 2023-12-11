# コンフリクトの解消
[ここのサイト](http://elsur.xyz/github-merge-failed)がわかりやすかった.  
ただ少し違う方法でもできた？

`This branch is 119 commits ahead, 4 commits behind master.`
のようにmasterと作業中のブランチがコンフリクトしている場合にどう対処するか.  

1. 新しくブランチを作る  
2. コピーしたブランチにmasterをマージする  
3. コンフリクトが出ていると言われるので, 当該箇所をローカルで修正  
4. addしてコミット  
5. masterに移動  
6. コピーしたブランチをmasterにmerge  
7. push
