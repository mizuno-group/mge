# python + R env
FROM continuumio/miniconda3

# indicate the version
ENV SALMON_VERSION 1.9.0
ENV PRINSEQ_VERSION 1.2.3
ENV R_BASE_VERSION 4.2.1

# craete each conda env
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda update -y -n base -c defaults conda && \
    conda create -n prinseq prinseq-plus-plus==${PRINSEQ_VERSION} && \
    conda create -n salmon salmon==${SALMON_VERSION} pandas && \
    conda create -n tximport r-base==${R_BASE_VERSION} gcc && \
    conda clean --all -f -y

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y libxml2-dev libcurl4-gnutls-dev libssl-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*	

RUN . /etc/profile.d/conda.sh && \
    conda activate && \
    conda activate tximport && \
    R -e "install.packages('BiocManager',repos='https://cran.ism.ac.jp/')" && \
    R -e "BiocManager::install('GenomicFeatures')" && \
    R -e "BiocManager::install('tximport')" && \
    R -e "BiocManager::install('readr')"

RUN mkdir /workspace
WORKDIR /workspace

# copy main files
COPY prinseq.sh /prinseq.sh
COPY salmon.sh /salmon.sh
COPY tximport.R /tximport.R
COPY prep_index.sh /prep_index.sh
COPY integrate.py /integrate.py
COPY main.sh /main.sh

RUN chmod 777 /prinseq.sh && \
    chmod 777 /salmon.sh && \
    chmod 777 /prep_index.sh && \
    chmod 777 /tximport.R && \
    chmod 777 /integrate.py && \
    chmod 777 /main.sh
