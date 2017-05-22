#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --time=4:00:00
#SBATCH --output=index_bwa_ref.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./


ref=citrus.trimmedReads.10kb.fasta
module load bwa/0.7.15

bwa index $ref

echo "Done"

