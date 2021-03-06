#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem=10G
#SBATCH --time=10:00:00
#SBATCH --output=Step0_map_blasr_array.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./

#sbatch --array 1-47 Step0_map_blasr_array.sh

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

module load blasr/5.2
#ref=Fairchild.fasta_contig.fasta
ref=Fairchild_chr1.fasta_contig.fasta
#reads=pool_asm.test.10kb.fasta_contig.fasta
reads=test1a.fq_split_asm_merge.10kb.fasta_contig.fasta

#run split fasta before run this shell
#perl fastaDeal.pl --cuts 1000 $reads

FILE=`ls $reads\.cut/*.f*a | head -n $N | tail -n 1`
echo "Run blasr on file: $FILE"
blasr $FILE $ref -m 1 --nproc $CPU > $FILE\.chr1.blasr.output.m1

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
