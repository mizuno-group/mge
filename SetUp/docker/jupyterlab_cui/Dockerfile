FROM jupyter/scipy-notebook

RUN conda install -c bioconda -c conda-forge salmon && \
    conda install -c bioconda -c conda-forge prinseq-plus-plus && \
    conda clean --all -f -y

EXPOSE 8888

ENTRYPOINT ["jupyter-lab","--ip=0.0.0.0","--port=8888","--no-browser","--allow-root","--NotebookApp.token=''"]