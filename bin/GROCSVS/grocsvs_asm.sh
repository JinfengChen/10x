#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=10
#SBATCH --mem=200G
#SBATCH --time=40:00:00
#SBATCH --output=grocsvs_asm.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./


start=`date +%s`

CPU=$SLURM_NTASKS
if [ ! $CPU ]; then
   CPU=2
fi

N=$SLURM_ARRAY_TASK_ID
if [ ! $N ]; then
    N=1
fi

echo "CPU: $CPU"
echo "N: $N"

#config=./grocsvs_fairchild/configuration.json
config=./grocsvs_fairchild/configuration_bionano.json
python=/bigdata/stajichlab/cjinfeng/00.RD/Assembly/10xgenomics/tools/GROCSVS/grocsvs_env/bin/python
export PATH=~/BigData/00.RD/Assembly/10xgenomics/tools/GROCSVS/bin:$PATH
export PYTHONPATH=/rhome/cjinfeng/BigData/software/miniconda2/envs/GROCSVS/lib/python2.7/site-packages/:~/BigData/software/pythonlib/pygraphviz/lib/python2.7/site-packages/:/rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/tools/GROCSVS/grocsvs_env/lib/python2.7/site-packages:$PYTHONPATH
#~/BigData/00.RD/Assembly/10xgenomics/tools/GROCSVS/grocsvs_env/bin/grocsvs --multiprocessing $config
~/BigData/00.RD/Assembly/10xgenomics/tools/GROCSVS/GROCSVS_asm/grocsvs/grocsvs_env/bin/grocsvs --multiprocessing $config
#$python /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/GROCSVS/Region_10x_similarity.py --multiprocessing $config


#h5dump BarcodeOverlapsStep/bcoverlaps.tumor.10X_tumor.chr13.chr1.2.4.hdf5 |grep ", 1,"
#python read_pickle.py | less -S

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
