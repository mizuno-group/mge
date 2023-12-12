# 元はdebianであることに注意
FROM continuumio/miniconda3

RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda install prinseq-plus-plus && \
    conda clean --all -f -y

RUN mkdir /workspace

WORKDIR /workspace

COPY main.sh /main.sh
RUN chmod 777 /main.sh