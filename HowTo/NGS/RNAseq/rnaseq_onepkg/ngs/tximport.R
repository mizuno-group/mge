#!/usr/bin/env Rscript

# description
# main runner for tximoprt
# inspired by https://ycl6.gitbook.io/guide-to-rna-seq-analysis/differential-expression-analysis/tximport

ver <- "1.0.2"

# get arguments
args <- commandArgs(trailingOnly=TRUE)
# default arguments
def_args <- c("__NONE","__NONE","__NONE")
def_flg <- is.na(args[1:3])
args[def_flg] <- def_args[def_flg]
# set arguments
url <- as.character(args[1])
species <- as.character(args[2])
storage <- as.character(args[3])

# library
library(GenomicFeatures)
library(tximport)
library(jsonlite)
library(readr)

# main
getwd()
tryCatch(
  {setwd(url)}
  , error = function(e){
      message("!! Give correct path for salmon result !!")
      }
) 

# prepare path
url_par <- sub('/res_salmon','',url)
gtf_path <- species

# prepare txdb
if (storage == "__NONE") {
  print('--- download GTF ---')
  fname <- strsplit(gtf_path,"/")
  fname <- unlist(fname)
  fname0 <- fname[length(fname)]
  fname <- paste(url_par,fname0,sep="/")
  options(timeout=600)
  download.file(gtf_path,destfile = fname)
  gtf_dir <- paste(url_par,"GTF",sep="/")
  if (dir.exists(gtf_dir)) {
    
  } else {
    dir.create(gtf_dir)
  }
  new_fname <- paste(gtf_dir,fname0,sep="/")
  file.copy(from=fname,to=new_fname)
  file.remove(fname)
  print('--- DONE ---')
  txdb <- makeTxDbFromGFF(new_fname)
} else {
  txdb <- makeTxDbFromGFF(storage)
}
k <- keys(txdb, keytype = "TXNAME")
tx2gene <- select(txdb, k, "GENEID", "TXNAME")

# load salmon files
salmon.files <- file.path(list.files(url,pattern="salmon_"),"quant.sf")
fnames <- c(list.files(url,pattern="salmon_"))
fnames <- sub("salmon_","",fnames)
fnames <- sub("_1_good_out_R1","",fnames)
names(salmon.files) <- fnames

tx_path <- paste(url_par,"res_tx",sep="/")
gene_path <- paste(url_par,"res_gene",sep="/")
dir.create(tx_path)
dir.create(gene_path)
x <- 1:length(salmon.files)
for (i in x) {
  cat(">> converting file #",i)
  temp_t <- tximport(salmon.files[i],type="salmon",txOut=TRUE)
  temp_g <- summarizeToGene(temp_t, tx2gene, countsFromAbundance = "scaledTPM")
  temp_n <- fnames[i]
  out_t <- paste(tx_path,"/",fnames[i],".csv",sep="")
  out_g <- paste(gene_path,"/",fnames[i],".csv",sep="")
  write.csv(temp_t$counts,file=out_t)
  write.csv(temp_g$counts,file=out_g)
}

# history
# 220905 move to one package
# 220802 hard url to config.txt
# 220723 Major: change paths to relative ones
# 211228 start writing