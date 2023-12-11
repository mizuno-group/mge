# applicationごとに個別にDockerfileを作る
FROM r-base

RUN apt-get update && \
    apt-get install -y libmysqlclient-dev libxml2-dev libcurl4-gnutls-dev libssl-dev && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/*
     
RUN R -e "install.packages('BiocManager',repos='https://cran.ism.ac.jp/')" && \
    R -e "BiocManager::install('GenomicFeatures')" && \
    R -e "BiocManager::install('tximport')" && \
    R -e "BiocManager::install('readr')"

# 以降は基本触らない
# /workspaceを作ってworkdirにすること, 各applicationのrunnerとしてmain.shを用意する形式は変えない
# main.shには実行権限を与えておく
# コンテナに使用させるモジュールが増える場合には適宜COPYと権限付与を追加する
# Rでも同様
RUN mkdir /workspace
WORKDIR /workspace
COPY main.R /main.R
RUN chmod 777 /main.R