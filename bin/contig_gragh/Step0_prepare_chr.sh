#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --time=40:00:00
#SBATCH --output=Step0_prepare_chr.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./

start=`date +%s`
#sbatch --array 1-9 Step0_prepare_chr.sh

module load blasr/5.2
module load bwa/0.7.15

ref=Fairchild_chr1.fasta_contig.fasta
chr=$SLURM_ARRAY_TASK_ID
perl ~/BigData/software/bin/fastaDeal.pl --get_id chr$chr ~/BigData/00.RD/Assembly/Pacbio/ALLMAPS/Citrus_falconv3_20kb_cov2_p_ctg_quiver_round1_haplomerge_10x_bionano_hybrid/out.fasta > Fairchild_chr$chr\.fasta
perl ~/BigData/software/bin/sumNxx.pl Fairchild_chr$chr\.fasta > Fairchild_chr$chr\.fasta.NXX
perl make_contigs_from_fasta_1line.pl Fairchild_chr$chr\.fasta
bwa index Fairchild_chr$chr\.fasta_contig.fasta

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"

