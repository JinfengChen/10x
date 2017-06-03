#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=40G
#SBATCH --time=40:00:00
#SBATCH --output=Step0_map_bwa.sh.stdout
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
module load bwa/0.7.15
#ref=Fairchild.fasta_contig.fasta
#ref=Fairchild_chr5.fasta_contig.fasta
#ref=Fairchild_chrUN.fasta_contig.fasta
#ref=Fairchild_chr8.fasta_contig.fasta
#ref=fairchild_graph_57G_chr7_bwa_merge/Final_Ref.fasta
#reads=pool_asm.test.10kb.fasta_contig.fasta
#reads=test1a.fq_split_asm_merge.10kb.fasta_contig.fasta
ref=Final_Ref.fasta
#run split fasta before run this shell
#perl fastaDeal.pl --cuts 1000 $reads

bwa index $ref
python /rhome/cjinfeng/BigData/software/bin/fasta2fastq.py $ref $ref\.fq
bwa mem -t $CPU $ref $ref\.fq > $ref\.sam
perl /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/tools/ncomms15324-s10/sam2blasr.pl $ref\.sam $ref\.m1

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
