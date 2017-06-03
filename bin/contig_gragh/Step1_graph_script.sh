#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=100G
#SBATCH --time=40:00:00
#SBATCH --output=run_speedseq_qsub.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./

start=`date +%s`

module load blasr/5.2

align=test.blasr.out
#ref=Fairchild.fasta_contig.fasta
ref=Fairchild_chr8.fasta_contig.fasta
#ref=Fairchild_chr1.fasta_contig_chrUN.fasta
#ref=Fairchild_canu1_3.fa_contig.fasta
#reads=Citrus10x.fasta_contig.fasta
#reads=Fairchild_canu1_3.fa_contig.fasta
#reads=Fairchild_DBG2OCL_raw_cns_pilon.fasta_contig.fasta
reads=pool_asm.test.10kb.fasta_contig.fasta
#reads=test1a.fq_split_asm_merge.10kb.fasta_contig.fasta
script=/rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/tools/ncomms15324-s10/
output=fairchild_graph
perl ../../tools/ncomms15324-s10/Fragment_Guided_Graph_Assembly.pl -Align=$align -Ref=$ref -Query=$reads -Script=$script -OutDir=$output -MinIden=95 -MaxHang=10000 -MinLap=5000 
chmod 755 Graph_Assembly.sh 
sbatch -p highmem Graph_Assembly.sh

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"

