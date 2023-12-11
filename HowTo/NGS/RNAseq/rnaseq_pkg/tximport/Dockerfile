FROM r-base

RUN apt-get update && \
    apt-get install -y libmysqlclient-dev libxml2-dev libcurl4-gnutls-dev libssl-dev && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/*
     
RUN R -e "install.packages('BiocManager',repos='https://cran.ism.ac.jp/')" && \
    R -e "BiocManager::install('GenomicFeatures')" && \
    R -e "BiocManager::install('tximport')" && \
    R -e "BiocManager::install('readr')"

RUN mkdir /workspace
WORKDIR /workspace

COPY main.R /main.R
RUN chmod 777 /main.R