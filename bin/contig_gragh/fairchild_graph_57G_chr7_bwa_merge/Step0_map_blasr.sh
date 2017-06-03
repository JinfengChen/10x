#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=50G
#SBATCH --time=40:00:00
#SBATCH --output=Step0_map_blasr.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./

start=`date +%s`

module load blasr/5.2

#perl ~/BigData/software/bin/make_contigs_from_fasta.pl Fairchild.fasta

#ref=/rhome/cjinfeng/BigData/00.RD/Assembly/Pacbio/Reference/Csinensis_HZAU/Citrus_HZAU.fa
#reads=/rhome/cjinfeng/BigData/00.RD/Assembly/Pacbio/PBcR/Pacbio_Citrus_32c_128G/Citrus/9-terminator/asm.scf.fasta
#ref=Fairchild.fasta_contig.fasta
#reads=pool_asm.test.10kb.fasta_contig.fasta
#ref=Final_Ref.fasta
ref=Final_Ref.fasta.cut/Final_Ref.fasta.1.fasta
reads=Final_Ref.fasta.cut/Final_Ref.fasta.2.fasta
#perl ../fastaDeal.pl --cuts 1 Final_Ref.fasta
#blasr Final_Ref.fasta.cut/Final_Ref.fasta.2.fasta Final_Ref.fasta.cut/Final_Ref.fasta.1.fasta -m 1 --nproc 24 > 2vs1.blasr.output.m1
blasr Final_Ref.fasta.cut/Final_Ref.fasta.3.fasta Final_Ref.fasta.cut/Final_Ref.fasta.1.fasta -m 1 --nproc 24 > 3vs1.blasr.output.m1
blasr Final_Ref.fasta.cut/Final_Ref.fasta.5.fasta Final_Ref.fasta.cut/Final_Ref.fasta.3.fasta -m 1 --nproc 24 > 5vs3.blasr.output.m1
blasr Final_Ref.fasta.cut/Final_Ref.fasta.5.fasta Final_Ref.fasta.cut/Final_Ref.fasta.4.fasta -m 1 --nproc 24 > 5vs4.blasr.output.m1
cat *vs*.blasr.output.m1 > contig.blasr.output.m1
perl ~/BigData/00.RD/Assembly/10xgenomics/tools/ncomms15324-s10/01-BLASRDeOverlap.pl contig.blasr.output.m1 Final_Ref.fasta Final_Ref.Self.fasta 5000 5000 95

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"

