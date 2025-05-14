#!/usr/bin/env bash
# yhbatch -N 1 -n 64 -p mars
# yhbatch -p e9 -n 1

smk=/XYFS01/HDD_POOL/gzfezx_shhli/gzfezx_shhlixy_2/BIGDATA2/gzfezx_shhli_2/USER/luozhenyu/script/mitoquest_smk/smkfile/run.all.smk
echo ""
echo "start = $(date)"
echo "$(hostname)"
snakemake=/HOME/gzfezx_shhli/gzfezx_shhlixy_2/BIGDATA2/gzfezx_shhli_2/miniconda3/envs/cnvnator/bin/snakemake
$snakemake -c 64 -pk -s ${smk} 2> snakemake.err.txt
echo "end = $(date)"
# echo "last status $? $(hostname)" |mail -s "job done: $(pwd)" luozhenyu@genomics.cn 
