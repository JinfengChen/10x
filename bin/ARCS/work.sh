echo "fairchild 10x"
ln -s ~/BigData/00.RD/Assembly/10xgenomics/bin/supernovo/fastq/ fairchild_10x_fastq
sbatch Step0_ARCS_fastq.sh
ln -s /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/ARCS/fairchild_10x_longranger_basic/outs/barcoded.fastq.gz citrus.barcoded.fastq.gz

