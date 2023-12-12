#!/bin/bash

# description
# prinseq runner

ver=1.0.0

# function for help
function usage {
  cat <<EOM
Usage: $(basename "$0") [OPTION] input_dir...
  -h          Display help
  -m VALUE    indicates single- or pair- end. choose 1 for single and 2 for pair
  -e VALUE    indicates the extension for fastq files
  -t VALUE    indicates the number of threads to be used, default 1
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

# function for single end
function single_end () {
  q1=()
  for f1 in *.${extension}; do
    q1+=($f1)
  done

  curr=`realpath $1`
  curr_par=`get_upper $1`
  make_tmp ${curr_par}

  for ix in ${!q1[@]}; do
    echo "--- iter "$ix" ---"
    temp=${q1[ix]}
    temp2=${temp/".${extension}"/''}
    echo $temp2
    prinseq++ -fastq ${q1[ix]} -out_name ${curr_par}/tmp_dir/${temp2} -threads ${threads} \
      -trim_left 5 -trim_tail_right 5 -trim_qual_right 30 -ns_max_n 20 -min_len 30
  done
  
  mkdir -p ${curr_par}/res_prinseq
  for g1 in ${curr_par}/tmp_dir/*.fastq; do
    if [[ ${g1} =~ "good_out" ]]; then
      mv ${g1} ${curr_par}/res_prinseq
    elif [[ ${g1} =~ "bad_out" ]] || [[ ${g1} =~ "single_out" ]]; then
      rm ${g1}
    else
      :
    fi
  done
  rm -rf ${curr_par}/tmp_dir
}

# function for pair end
function pair_end () {
  q1=()
  for f1 in *1.${extension}; do
    q1+=($f1)
  done
  q2=()
  for f2 in *2.${extension}; do
    q2+=($f2)
  done
  if [ ${#q1[@]} != ${#q2[@]} ]; then
    echo "!! The number of ends were mismatched !!"
    exit 1
  fi
  
  curr=`realpath $1`
  curr_par=`get_upper $1`
  make_tmp ${curr_par}

  for ix in ${!q1[@]}; do
    echo "--- iter "$ix" ---"
    temp=${q1[ix]}
    temp2=${temp/".${extension}"/''}
    echo $temp2
    prinseq++ -fastq ${q1[ix]} -fastq2 ${q2[ix]} -out_name ${curr_par}/tmp_dir/${temp2} -threads ${threads} \
      -trim_left 5 -trim_tail_right 5 -trim_qual_right 30 -ns_max_n 20 -min_len 30
  done
  
  mkdir -p ${curr_par}/res_prinseq
  for g1 in ${curr_par}/tmp_dir/*.fastq; do
    if [[ ${g1} =~ "good_out" ]]; then
      mv ${g1} ${curr_par}/res_prinseq
    elif [[ ${g1} =~ "bad_out" ]] || [[ ${g1} =~ "single_out" ]]; then
      rm ${g1}
    else
      :
    fi
  done
  rm -rf ${curr_par}/tmp_dir
}

# url argument check
if [ "$1" = "" ]; then
  echo "!! Give a path of the target directory containing fastq files !!"
  exit 1
fi

# option check
extension=fastq.gz
threads=1
flag=0
while getopts m:e:t:hv opt; do
  case "$opt" in
    m)
      if [ $OPTARG -eq 1 ]; then
        flag=1
      elif [ $OPTARG -eq 2 ]; then
        flag=2
      else
        echo '!! Wrong method: choose 1 for single- or 2 for pair-end !!'
        exit 1
      fi
      ;;
    h)
      usage
      exit
      ;;
    e)
      extension=$OPTARG
      ;;
    t)
      threads=$OPTARG
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
echo ">>> start prinseq++"

# move
pushd $1

# main
if [ $flag -eq 1 ]; then
  single_end $1
else
  pair_end $1
fi

# move back
popd

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

# history
# 220723 Major: change paths to relative ones
# 211227 start writing