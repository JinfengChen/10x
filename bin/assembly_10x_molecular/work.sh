echo "fastq format is interleaved fastq that used for ARCS with barcode in header"
#@E00526:73:HJW57ALXX:8:1106:27813:48863_AAACACCAGCGATATA
#AGGGATGAGCCAAGCATGTATTGCCTTAAATTCGTAGTCCCTATTCGCACGGCTCTTTGTACATTGATTCAAGATTCTTTTAACTTTCCACTAATTATATATCTAAATTACCAACTTTGATAATACC
#+
#JF<F-<A-<AJJFJJF-<F--<A<FFAJFA-FJ-FA<<AFAF7-<AFJJF--F--7---<7A<JFF--A-<FJAJ<7<--7---<FF7A<A-<FFJ<7AF---7AA--77-77----F--AFA7---
#@E00526:73:HJW57ALXX:8:1106:27813:48863_AAACACCAGCGATATA
#CTACACGACGCTCTTCGATCTAAACACCAGCGATATACGAAACTATATCGCTGGTGTTTAGATCGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATTAAAAAAATTTTTTTTTTTGAAGCAGAAAGACGAA
#+
#AAFFFJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJFJJJJJJAFJJJFJJJJJJJJJJ-AAJJJJJJJJJJJJJJJJJJJ<AJJJJFJJJJJ----<<--7-A------7-7<-------
ln -s /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/ARCS/citrus_CHROMIUM_interleaved.fastq.gz ./
~/BigData/software/seqtk-master/seqtk sample -s seed=11 citrus_CHROMIUM_interleaved.fastq.gz > citrus_CHROMIUM_interleaved.0.3.fastq
echo "error corrected Pacbio"
#falcon
ln -s ~/BigData/00.RD/Assembly/Pacbio/FALCON_v3.0/virtualenv/FALCON_v3.0/Citrus/Pacbio_raw_plus_20kb/2-asm-falcon_min2_12k/preads4falcon.fasta* ./
faFilter -minSize=10000 preads4falcon.fasta preads4falcon.10kb.fasta
perl ~/BigData/software/bin/sumNxx.pl preads4falcon.10kb.fasta > preads4falcon.10kb.fasta.NXX
perl ~/BigData/software/bin/fastaDeal.pl --attr id:len preads4falcon.10kb.fasta > preads4falcon.10kb.fasta.len
cut -f2 preads4falcon.10kb.fasta.len | perl ~/BigData/software/bin/numberStat.pl
#canu
cp /rhome/cjinfeng/BigData/00.RD/Assembly/Pacbio/install/Canu/canu-1.3/citrus_raw_plus_20kb_fasta/citrus.trimmedReads.fasta.gz ./
gunzip -d citrus.trimmedReads.fasta.gz 
perl ~/BigData/software/bin/sumNxx.pl citrus.trimmedReads.fasta > citrus.trimmedReads.fasta.NXX
perl ~/BigData/software/bin/fastaDeal.pl --attr id:len citrus.trimmedReads.fasta > citrus.trimmedReads.fasta.len
faFilter -minSize=10000 citrus.trimmedReads.fasta citrus.trimmedReads.10kb.fasta
perl ~/BigData/software/bin/sumNxx.pl citrus.trimmedReads.10kb.fasta > citrus.trimmedReads.10kb.fasta.NXX
perl ~/BigData/software/bin/fastaDeal.pl --attr id:len citrus.trimmedReads.10kb.fasta > citrus.trimmedReads.10kb.fasta.len
cut -f2 citrus.trimmedReads.fasta.len| perl ~/BigData/software/bin/numberStat.pl

