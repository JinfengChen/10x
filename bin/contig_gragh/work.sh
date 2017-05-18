
ln -s /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/supernovo/Citrus10x.fasta ./
ln -s /rhome/cjinfeng/Rice/Rice_population_sequence/BUSCO/Fairchild_falconv3_20kb_cov2_p_ctg_quiver_round1_pilon_haplomerge.fasta Fairchild.fasta
perl ~/BigData/software/bin/make_contigs_from_fasta.pl Fairchild.fasta
perl ~/BigData/software/bin/fastaDeal.pl --attr id:len Fairchild.fasta_contig.fasta > Fairchild.fasta_contig.fasta.len
perl ~/BigData/software/bin/make_contigs_from_fasta.pl Citrus10x.fasta
perl ~/BigData/software/bin/fastaDeal.pl --attr id:len Citrus10x.fasta_contig.fasta > Citrus10x.fasta_contig.fasta.len
awk '$2>10000' Citrus10x.fasta_contig.fasta.len | cut -f1 > Citrus10x.fasta_contig.10kb.id
perl getidseq.pl -l Citrus10x.fasta_contig.10kb.id -f Citrus10x.fasta_contig.fasta -o Citrus10x.fasta_contig.10kb.fasta

perl ~/BigData/software/bin/fastaDeal.pl --attr id:len Citrus10x.fasta > Citrus10x.fasta.len
awk '$2>10000' Citrus10x.fasta.len | cut -f1 > Citrus10x.10kb.id
perl getidseq.pl -l Citrus10x.10kb.id -f Citrus10x.fasta -o Citrus10x.10kb.fasta

