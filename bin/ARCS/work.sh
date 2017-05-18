echo "fairchild 10x"
perl ~/BigData/software/bin/fastaDeal.pl --attr id Fairchild.fa > Fairchild.reform.id
perl getidseq.pl -l Fairchild.reform.id -f Fairchild.fa -o Fairchild.reform.fa
perl rename_by_num.pl -f Fairchild.fa -o Fairchild.reform.fa
#ARCS
ln -s ~/BigData/00.RD/Assembly/10xgenomics/bin/supernovo/fastq/ fairchild_10x_fastq
sbatch Step0_ARCS_fastq.sh
ln -s /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/ARCS/fairchild_10x_longranger_basic/outs/barcoded.fastq.gz citrus.barcoded.fastq.gz
sbatch Step1_ARCS_align.sh

