#!/usr/bin/env Rscript

# description
# main runner for tximoprt
# inspired by https://ycl6.gitbook.io/guide-to-rna-seq-analysis/differential-expression-analysis/tximport

# history and version
# 211228 start writing
ver <- "0.0.1"

# Hard conding for GTF
# downloaded from https://www.gencodegenes.org/human/
# or https://may2021.archive.ensembl.org/Rattus_norvegicus/Info/Index
HUMAN <- "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_39/gencode.v39.annotation.gtf.gz"
MOUSE <- "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M28/gencode.vM28.annotation.gtf.gz"
RAT <- "http://ftp.ensembl.org/pub/release-104/gtf/rattus_norvegicus/Rattus_norvegicus.Rnor_6.0.104.gtf.gz"

# get arguments
args <- commandArgs(trailingOnly=TRUE)
# default arguments
def_args <- c("__NONE","/workspace/res_salmon","__NONE")
def_flg <- is.na(args[1:3])
args[def_flg] <- def_args[def_flg]
# set arguments
species <- as.character(args[1])
url <- as.character(args[2])
storage <- as.character(args[3])

# library
library(GenomicFeatures)
library(tximport)
library(jsonlite)
library(readr)

# species check
if ((species == "-h") || (species == "--human")) {
  gtf_path <- HUMAN
} else if ((species == "-m") || (species == "--mouse")) {
  gtf_path <- MOUSE
} else if ((species == "-r") || (species == "--rat")) {
  gtf_path <- RAT
} else {
  print("!! Indicate species: -h, -m, and -r for human, mouse, and rat, respectively !!")
  Q
}

# main
getwd()
setwd(url)

# prepare txdb
# deleted (for escape from rat error)

# load salmon files
salmon.files <- file.path(list.files(".",pattern="salmon_"),"quant.sf")
fnames <- c(list.files(".",pattern="salmon_"))
fnames <- sub("salmon_","",fnames)
fnames <- sub("_1_good_out_R1","",fnames)
names(salmon.files) <- fnames

dir.create("/workspace/res_tx")
dir.create("/workspace/res_gene")
x <- 1:length(salmon.files)
for (i in x) {
  cat(">> converting file #",i)
  temp_t <- tximport(salmon.files[i],type="salmon",txOut=TRUE)
  tx2gene <- data.frame(TXNAME=rownames(temp_t$counts), GENEID = sapply(strsplit(rownames(temp_t$counts), '\\.'), '[', 1))
  temp_g <- summarizeToGene(temp_t, tx2gene, countsFromAbundance = "scaledTPM")
  temp_n <- fnames[i]
  out_t <- paste("/workspace/res_tx/",fnames[i],".csv",sep="")
  out_g <- paste("/workspace/res_gene/",fnames[i],".csv",sep="")
  write.csv(temp_t$counts,file=out_t)
  write.csv(temp_g$counts,file=out_g)
}