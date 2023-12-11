# applicationごとに個別にDockerfileを作る

FROM continuumio/miniconda3

RUN conda update conda && \
    conda install -c conda-forge -c bioconda -y pandas salmon==1.8.0 && \
    conda clean --all -f -y

RUN apt-get update -y && apt-get install -y curl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*	

# 以降は基本触らない
# /workspaceを作ってworkdirにすること, 各applicationのrunnerとしてmain.shを用意する形式は変えない
# main.shには実行権限を与えておく
# コンテナに使用させるモジュールが増える場合には適宜COPYと権限付与を追加する
RUN mkdir /workspace
WORKDIR /workspace
COPY main.sh /main.sh
RUN chmod 777 /main.sh
COPY python_module.py /python_module.py
RUN chmod 777 /python_module.py