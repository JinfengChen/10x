#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --time=40:00:00
#SBATCH --output=Step1_ARCS_align.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./

#sbatch --array 1 run_speedseq_qsub.sh

export PATH="/rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/tools/arcs/bin:/rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/tools/longranger/longranger-2.1.3:$PATH"

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


module load samtools/1.3
module load bwa/0.7.12 
#fastq file from longranger basic
fastq=citrus.barcoded.fastq.gz
#scaffold to link
ref=ecoli_ass.fa
prefix=citrus
echo "Prepare CHROMIUM interleaved fastq file"
if [ ! -e $prefix\_CHROMIUM_interleaved.fastq.gz ]; then
   /usr/bin/unpigz -c $fastq | perl -ne 'chomp;$ct++;$ct=1 if($ct>4);if($ct==1){if(/(\@\S+)\sBX\:Z\:(\S{16})/){$flag=1;$head=$1."_".$2;print "$head\n";}else{$flag=0;}}else{print "$_\n" if($flag);}' > $prefix\_CHROMIUM_interleaved.fastq
   pigz $prefix\_CHROMIUM_interleaved.fastq -p $CPU
fi

echo "Align reads by BWA mem"
if [ ! -e $prefix\.CHROMIUM-sorted.bam ]; then
   bwa index $ref
   bwa mem -t24 $ref -p $prefix\_CHROMIUM_interleaved.fastq.gz | samtools view -Sb - | samtools sort -n - -o $prefix\.CHROMIUM-sorted.bam
fi

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
