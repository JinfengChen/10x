echo "prepare"
cd supernovo/fastq/
ln -s ~/BigData/00.RD/Assembly/10xgenomics/input/Fairchild_10x/Citrus10x-*_R*_001.fastq.gz ./
cd ..
echo "fastqc"
sbatch fastqc.sh
echo "assembly"
sbatch supernovo.sh

