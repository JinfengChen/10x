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
ref=Fairchild.fasta_contig.fasta
reads=Citrus10x.fasta_contig.10kb.fasta
script=/rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/tools/ncomms15324-s10/
output=fairchild_graph
perl ../../tools/ncomms15324-s10/Fragment_Guided_Graph_Assembly.pl -Align=$align -Ref=$ref -Query=$reads -Script=$script -OutDir=$output -MinIden=99 -MaxHang=1000 -MinLap=5000 
chmod 755 Graph_Assembly.sh 
sbatch Graph_Assembly.sh

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
