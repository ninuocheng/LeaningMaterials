#!/bin/bash
GPU=$(nvidia-smi -L|awk -F'[)| ]' '{print $(NF-1)}' |sed 's#GPU-##')
sed -i 's#.*NEPTUNE_DEFAULT_GPU.*#export NEPTUNE_DEFAULT_GPU="'$GPU'"#' /opt/lotusworker/worker-p2/start_p2.sh
