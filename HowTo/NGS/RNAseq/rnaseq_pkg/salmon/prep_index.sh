#!/bin/bash

# description
# prepare salmon index
# inspired by https://combine-lab.github.io/alevin-tutorial/2019/selective-alignment/
# downloaded from https://www.gencodegenes.org/human/
# or https://may2021.archive.ensembl.org/Rattus_norvegicus/Info/Index

ver=1.0.1

# function for help
function usage {
  cat <<EOM
Usage: $(basename "$0") input_dir transcripts genome [OPTION] output_dir...
  -s VALUE    indicates the target species
  -t VALUE    indicates the number of threads to be used
  -e VALUE    indicates the extension for fastq files
EOM

  exit 2
}

# get absolute path
realpath() {
  case "$1" in /*) ;; *) printf '%s/' "$PWD";; esac; echo "$1"
}

# get absolute path of the parent dir of the given
function get_upper () {
  curr_path=`case "$1" in /*) ;; *) printf '%s/' "$PWD";; esac; echo "$1"`
  curr_name=`basename ${curr_path}`
  echo ${curr_path//"/${curr_name}"/}
}

# make tmp_dir under the given
function make_tmp () {
  tmp_path=${1}/tmp_dir
  if [ -e ${tmp_path} ]; then
      rm -rf ${tmp_path}
  fi
  mkdir ${tmp_path}
}

# option check
extension=fa.gz
threads=12
flag=0
species="human"
while getopts t:e:s:v opt; do
  case "$opt" in
    s)
      species=$OPTARG
      ;;
    t)
      threads=$OPTARG
      ;;
    e)
      extension=$OPTARG
      ;;
    v)
      echo "v$ver"
      exit
      ;;
    \?)
      echo '!! Unexpected argument !!'
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# main function
# display time
sta=`date +%s`

# main loop

curr=`realpath $1`
transcripts=$2
genomes=$3

curr_par=`get_upper ${curr}`
make_tmp ${curr_par}
tmp_path=${curr_par}/tmp_dir

# download
temp_t=${transcripts}
temp_g=${genomes}
list_t=(${temp_t//\// })
list_g=(${temp_g//\// })
name_t=${list_t[-1]}
name_g=${list_g[-1]}
path_t=${tmp_path}/${name_t}
path_g=${tmp_path}/${name_g}
if [ -f ${path_t} ]; then
  echo "${name_t} download is already completed"
else
  curl -k $temp_t -o ${path_t}
fi
if [ -f ${path_g} ]; then
  echo "${name_g} download is already completed"
else
  curl -k $temp_g -o ${path_g}
fi

# prepare decoy
grep "^>" <(gunzip -c ${path_g}) | cut -d " " -f 1 > ${tmp_path}/decoys_${species}.txt
sed -i.bak -e 's/>//g' ${tmp_path}/decoys_${species}.txt

# concatenate sequences
cat ${path_t} ${path_g} > ${tmp_path}/gentrome_${species}.${extension}

# salmon index
name_f=${name_t//\.${extension}/}
if [ ${species} = "rat" ]; then
  echo "not using --gencode flag"
  salmon index -t ${tmp_path}/gentrome_${species}.${extension} \
    -d ${tmp_path}/decoys_${species}.txt \
    -p ${threads} \
    -i ${tmp_path}/salmon_index_${name_f}
else
  salmon index -t ${tmp_path}/gentrome_${species}.${extension} \
    -d ${tmp_path}/decoys_${species}.txt \
    -p ${threads} \
    -i ${tmp_path}/salmon_index_${name_f} --gencode
fi

# clean up directories
rm ${tmp_path}/decoys_${species}.txt.bak
mv ${tmp_path}/ ${curr_par}/salmon_indices

# display time
end=`date +%s`
pt=`expr ${end} - ${sta}`
hr=`expr ${pt} / 3600`
pt=`expr ${pt} % 3600`
mi=`expr ${pt} / 60`
se=`expr ${pt} % 60`
echo ">>> end"
echo "--- Elapsed Time ---"
echo "${hr} h ${mi} m ${se} s"
echo "--------------------"


# history and version
# 220802 hard url to config.txt
# 220723 Major: change paths to relative ones
# 220606 fix curl certification error
# 211228 start writing