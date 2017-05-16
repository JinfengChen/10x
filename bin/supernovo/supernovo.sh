#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=200G
#SBATCH --time=100:00:00
#SBATCH --output=stdout
#SBATCH -p intel
#SBATCH --workdir=./

#sbatch --array 1 run_speedseq_qsub.sh

module load supernova
start=`date +%s`

MEM=180
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

#rm ASSEMBLER_CP to restart unfinished run
#supernova run --fastqs=./fastq --sample=Citrus10x --id=fairchild_run --localcores=$CPU --localmem=$MEM
supernova mkoutput --asmdir=fairchild_run/outs/assembly --outprefix=Citrus10x --style=pseudohap --minsize=2000 --headers=short
gunzip -d Citrus10x.fasta.gz
perl ~/BigData/software/bin/sumNxx.pl Citrus10x.fasta > Citrus10x.fasta.NXX

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
