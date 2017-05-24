
ln -s /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/supernovo/Citrus10x.fasta ./
ln -s /rhome/cjinfeng/Rice/Rice_population_sequence/BUSCO/Fairchild_falconv3_20kb_cov2_p_ctg_quiver_round1_pilon_haplomerge.fasta Fairchild.fasta
perl make_contigs_from_fasta_1line.pl Fairchild.fasta
perl ~/BigData/software/bin/fastaDeal.pl --attr id:len Fairchild.fasta_contig.fasta > Fairchild.fasta_contig.fasta.len
perl make_contigs_from_fasta_1line.pl Citrus10x.fasta
perl ~/BigData/software/bin/fastaDeal.pl --attr id:len Citrus10x.fasta_contig.fasta > Citrus10x.fasta_contig.fasta.len
awk '$2>10000' Citrus10x.fasta_contig.fasta.len | cut -f1 > Citrus10x.fasta_contig.10kb.id
perl getidseq.pl -l Citrus10x.fasta_contig.10kb.id -f Citrus10x.fasta_contig.fasta -o Citrus10x.fasta_contig.10kb.fasta

sbatch Step0_map_blasr.sh
bash Step1_graph_script.sh

echo "pool assembly 10x"
ln -s ~/BigData/00.RD/Assembly/10xgenomics/bin/assembly_10x_molecular/test1.fq_split_asm_merge.fasta pool_asm.test.fasta
faFilter -minSize=10000 pool_asm.test.fasta pool_asm.test.10kb.fasta
perl make_contigs_from_fasta_1line.pl pool_asm.test.10kb.fasta
sbatch Step0_map_blasr.sh
bash Step1_graph_script.sh

