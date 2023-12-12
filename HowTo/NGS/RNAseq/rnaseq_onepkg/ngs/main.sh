#!/bin/bash
conda init bash
. ~/.bashrc
ver=1.1.0

# load config
sed -i 's/\r//' ./config.txt
source ./config.txt
source ./.env

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

# preparation
echo ">> configuration"
cat config.txt
if [[ "${INPUT_DIR}" == *${BSRC}* ]]; then
  host_input=`realpath ${INPUT_DIR}`
  cont_input=`echo ${host_input//${BSRC}/"/workspace"}`
else
  echo "!! ERROR: INPUT_DIR should be under BSRC !!"
  echo ">> Note: given as a path in the host"
  exit 1
fi
echo "<< end"

host_par=`get_upper ${host_input}`
cont_par=`get_upper ${cont_input}`

# run prinseq
if [ ${SEQ_END} = "single" ]; then
  bash /prinseq.sh -e ${EXTENSION} -m 1 -g ${RES_ONLY} ${cont_input}
elif [ ${SEQ_END} = "pair" ]; then
  bash /prinseq.sh -e ${EXTENSION} -m 2 -g ${RES_ONLY} ${cont_input}
else
  echo "!! ERROR: SEQ_END should be single or pair !!"
  exit 1
fi  
echo ">> prinseq status: $?"

# run salmon
if [ ${SPECIES} = "human" ]; then
  salmon_tx=${HUMAN_Tx}
  salmon_gen=${HUMAN_Gen}
elif [ ${SPECIES} = "mouse" ]; then
  salmon_tx=${MOUSE_Tx}
  salmon_gen=${MOUSE_Gen}
elif [ ${SPECIES} = "rat" ]; then
  salmon_tx=${RAT_Tx}
  salmon_gen=${RAT_Gen}
else
  echo "!! ERROR: SPECIES should be human, mouse, or rat !!"
  exit 1
fi
if [ -z "${SALMON_IDX_PATH}" ]; then
  bash /prep_index.sh ${cont_input} ${salmon_tx} ${salmon_gen}
  SALMON_IDX_PATH=`find ${cont_par}/salmon_indices -maxdepth 1 -type d -name "salmon_index_*"`
  if [ -z "${SALMON_IDX_PATH}" ]; then
    echo "!! ERROR: prep_index.sh did not work unexpectedly !!"
    exit 1
  fi
fi
cont_idx=`echo ${SALMON_IDX_PATH//${BSRC}/"/workspace"}`
if [ ${SEQ_END} = "single" ]; then
  bash /salmon.sh -m 1 -d ${RES_ONLY} ${cont_par}/res_prinseq ${cont_idx}
elif [ ${SEQ_END} = "pair" ]; then
  bash /salmon.sh -m 2 -d ${RES_ONLY} ${cont_par}/res_prinseq ${cont_idx}
else
  echo "!! ERROR: SEQ_END should be single or pair !!"
  exit 1
fi
echo ">> salmon status: $?"

# run tximport
conda activate tximport
if [ ${SPECIES} = "human" ]; then
  url_gtf=${HUMAN_GTF}
elif [ ${SPECIES} = "mouse" ]; then
  url_gtf=${MOUSE_GTF}
elif [ ${SPECIES} = "rat" ]; then
  url_gtf=${RAT_GTF}
else
  echo "!! ERROR: SPECIES should be human, mouse, or rat !!"
  exit 1
fi
if [ -z "${TX_GTF_PATH}" ]; then
  Rscript /tximport.R ${cont_par}/res_salmon ${url_gtf}
else
  cont_gtf=`echo ${TX_GTF_PATH//${BSRC}/"/workspace"}`
  Rscript /tximport.R ${cont_par}/res_salmon ${url_gtf} ${cont_gtf}
fi
echo ">> tximport status: $?"

# summary
conda activate salmon
python /integrate.py -i ${cont_par}/res_gene -o ${OUTPUT_EXP}
python /integrate.py -i ${cont_par}/res_tx -o ${OUTPUT_TX}
mkdir ${cont_par}/res_summary
mv ${cont_par}/res_gene/${OUTPUT_EXP}.txt ${cont_par}/res_tx/${OUTPUT_TX}.txt ${cont_par}/res_summary/.

if [ -e ${cont_par}/result ]; then
  res_path=${cont_par}/result_new
else
  res_path=${cont_par}/result
fi

if "${RES_ONLY}"; then
  mv -T ${cont_par}/res_summary ${res_path}
  rm -rf ${cont_par}/res_prinseq \
    ${cont_par}/res_salmon \
    ${cont_par}/res_gene \
    ${cont_par}/res_tx
else
  mkdir ${res_path}
  mv ${cont_par}/res_prinseq \
    ${cont_par}/res_salmon \
    ${cont_par}/res_gene \
    ${cont_par}/res_tx \
    ${cont_par}/res_summary \
    ${res_path}/.
fi

echo "=== completed ==="

# history
# 220905 summarize into one docker file 
# 220802 handling seq end; fix wrong if sentence @line 49; add res_only mode
# 220723 start writing