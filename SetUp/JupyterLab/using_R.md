# JupyterLabでRを使用

以下に準拠

https://engineeeer.com/windows-anaconda-jupyternotebook-r/

Rで

install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))

devtools::install_github('IRkernel/IRkernel')

を実行。

その後、anaconda promptでRを入れたい環境をactivate。入れたいRのbinaryを実行する。

例えば、

cd "C:\Program Files\R\R-3.6.2\bin\x64"

.\R

でRを起動。Rstdioを使っている場合にどうすればよいかは調査中。

開いたR上で

IRkernel::installspec()

を実行。