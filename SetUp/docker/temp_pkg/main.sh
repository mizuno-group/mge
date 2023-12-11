#!/bin/bash

ver=1.0.0

### load config
# configを読み込む際に改行コードを無視するようsedでケアしておく
# ホストとコンテナのパスを行き来するために.envも読み込む
sed -i 's/\r//' ./config.txt
source ./config.txt
source ./.env

### functions
# 適宜使用する関数を事前に定義しておく
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

# convert the host path to the container path
function to_container () {
  input=`realpath ${1}`
  echo ${input//${BSRC}/"/workspace"}
}

### error check
# input dirとbind先の関係性チェック, inputはbind以下にあること
if [[ "${INPUT_DIR}" == *${BSRC}* ]]; then
  host_input=`realpath ${INPUT_DIR}`
  cont_input=`echo ${host_input//${BSRC}/"/workspace"}`
else
  echo "!! ERROR: INPUT_DIR should be under BSRC !!"
  echo ">> Note: given as a path in the host"
  exit 1
fi

### main
# run app1
docker-compose exec app1 /main.sh

# run app2
# pythonの場合
docker-compose exec app2 python python_module.py

# run app3
# Rの場合
docker-compose exec app3 Rscript main.R

### summary
# 出力先の確認, 元々あるようならresult_newなどとしておく
if [ -e ${cont_par}/result ]; then
  res_path=${cont_par}/result_new
else
  res_path=${cont_par}/result
fi
docker-compose exec salmon mkdir ${res_path}
docker-compose exec salmon mv ${cont_par}/res_prinseq \
  ${cont_par}/res_salmon \
  ${cont_par}/res_gene \
  ${cont_par}/res_tx \
  ${cont_par}/res_summary \
  ${res_path}/.

echo "=== completed ==="

# history
# 220723 start writing