# 元はdebianであることに注意
# history
# 220606 update salmon and tbb version to 1.8.0 because of index error
# 211228 update salmon version to 1.6.0 because of rat error
# 211228 fixed libtbb.so.2 related error by version indicated DL
# 211228 indicated the version of salmon since it was very old (v0.13.0)

FROM continuumio/miniconda3

RUN conda update conda && \
    conda install -c conda-forge -c bioconda -y pandas salmon==1.8.0 && \
    conda clean --all -f -y

RUN apt-get update -y && apt-get install -y curl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*	

RUN mkdir /workspace

WORKDIR /workspace

COPY main.sh /main.sh
RUN chmod 777 /main.sh
COPY prep_index.sh /prep_index.sh
RUN chmod 777 /prep_index.sh
COPY integrate.py /integrate.py
RUN chmod 777 /integrate.py