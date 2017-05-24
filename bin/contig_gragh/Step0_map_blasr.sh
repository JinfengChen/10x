#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=50G
#SBATCH --time=40:00:00
#SBATCH --output=run_speedseq_qsub.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./

start=`date +%s`

module load blasr/5.2

#perl ~/BigData/software/bin/make_contigs_from_fasta.pl Fairchild.fasta

#ref=/rhome/cjinfeng/BigData/00.RD/Assembly/Pacbio/Reference/Csinensis_HZAU/Citrus_HZAU.fa
#reads=/rhome/cjinfeng/BigData/00.RD/Assembly/Pacbio/PBcR/Pacbio_Citrus_32c_128G/Citrus/9-terminator/asm.scf.fasta
ref=Fairchild.fasta_contig.fasta
reads=pool_asm.test.10kb.fasta_contig.fasta
#reads=Citrus10x.fasta_contig.10kb.fasta
#/opt/blasr/453c25ab/bin//sawriter $ref.sa $ref
#$blasr $reads $ref -sa $ref.sa -rbao -minMatch 40 -advanceExactMatches 40 -noRefineAlignments -affineAlign -affineOpen 100 -affineExtend 0 -sam -nproc 2 | /usr/local/bin/samtools view -bhS - > Citrus_ctg2genome.blasr.raw.bam
blasr $reads $ref -m 1 --nproc 24 > blasr.output.m1
#/usr/local/bin/samtools sort -m 1000000000 Citrus.blasr.raw.bam Citrus.corrected.blasr

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"

