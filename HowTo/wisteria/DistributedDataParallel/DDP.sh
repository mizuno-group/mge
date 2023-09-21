#!/bin/bash
#PJM -L rscgrp=regular-a
#PJM -L node=2
#PJM --mpi proc=2
#PJM -g ga97

module load cuda/11.8
module load cudnn/8.8.0
module load nccl/2.16.5
module load cmake/3.22.2
module load gcc/8.3.1
module load ompi/4.1.1

# source myenv/bin/activate

STR1=".d000"
STR2=$PJM_JOBID
STR3="_nodeinfo"

LINE=`cat "$STR1$STR2$STR3"`
IPS=()

while read line
do 
    echo $line
    IPS+=("$line")
done << FILE
$LINE
FILE

mpirun -machinefile $PJM_O_NODEINF -np $PJM_MPI_PROC -map-by node ./torchrun.sh ${IPS[0]}