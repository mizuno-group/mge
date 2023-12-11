# applicationごとに個別にDockerfileを作る
FROM continuumio/miniconda3

RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda install prinseq-plus-plus && \
    conda clean --all -f -y

# 以降は基本触らない
# /workspaceを作ってworkdirにすること, 各applicationのrunnerとしてmain.shを用意する形式は変えない
# main.shには実行権限を与えておく
# コンテナに使用させるモジュールが増える場合には適宜COPYと権限付与を追加する
RUN mkdir /workspace
WORKDIR /workspace
COPY main.sh /main.sh
RUN chmod 777 /main.sh