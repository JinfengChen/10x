
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
ln -s /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/assembly_10x_molecular/test1.fq_split_asm_merge.6.5G.fasta pool_asm.test.fasta
faFilter -minSize=10000 pool_asm.test.fasta pool_asm.test.10kb.fasta
perl make_contigs_from_fasta_1line.pl pool_asm.test.10kb.fasta
perl fastaDeal.pl --cuts 1000 pool_asm.test.10kb.fasta_contig.fasta 
sbatch --array 1-47 Step0_map_blasr_array.sh
cat pool_asm.test.10kb.fasta_contig.fasta.cut/pool_asm.test.10kb.fasta_contig.fasta.*.m1 > pool_asm.test.10kb.fasta_contig.fasta.cut.blasr.output.m1
cp pool_asm.test.10kb.fasta_contig.fasta.cut.blasr.output.m1 test.blasr.out
cut -f1 -d" " test.blasr.out | uniq | sort | uniq | wc -l
bash Step1_graph_script.sh

echo "add new asm to current set"
ln -s /rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/bin/assembly_10x_molecular/test1a.fq_split_asm_merge.fasta ./
#check last contig id: Contig_353271, then set my $tcas_id = 353272 in make_contigs_from_fasta_1line_add.pl 
grep ">" pool_asm.test.10kb.fasta_contig.fasta | tail 
faFilter -minSize=10000 test1a.fq_split_asm_merge.fasta test1a.fq_split_asm_merge.10kb.fasta
perl make_contigs_from_fasta_1line_add.pl test1a.fq_split_asm_merge.10kb.fasta
perl fastaDeal.pl --cuts 1000 test1a.fq_split_asm_merge.10kb.fasta_contig.fasta
sbatch -p highmem --array 1-150 Step0_map_blasr_array.sh
cat test1a.fq_split_asm_merge.10kb.fasta_contig.fasta.cut/*.m1 > test1a.fq_split_asm_merge.10kb.fasta_contig.fasta.cut.blasr.output.m1
cp test1a.fq_split_asm_merge.10kb.fasta_contig.fasta.cut.blasr.output.m1 test.blasr.out
cut -f1 -d" " test.blasr.out | uniq | sort | uniq | wc -l
cat Fairchild.fasta_contig.fasta.pool_asm.test.32G.10kb > test.blasr.out 
cat test1a.fq_split_asm_merge.10kb.fasta_contig.fasta.cut.blasr.output.m1 >> test.blasr.out
cat test1a.fq_split_asm_merge.10kb.fasta_contig.fasta >> pool_asm.test.10kb.fasta_contig.fasta

echo "chr1"
perl ~/BigData/software/bin/fastaDeal.pl --get_id chr1 ~/BigData/00.RD/Assembly/Pacbio/ALLMAPS/Citrus_falconv3_20kb_cov2_p_ctg_quiver_round1_haplomerge_10x_bionano_hybrid/out.fasta > Fairchild_chr1.fasta
perl make_contigs_from_fasta_1line.pl Fairchild_chr1.fasta
perl make_contigs_from_fasta_1line_add.pl Fairchild_chrUN.fasta
faFilter -minSize=10000 Fairchild_chrUN.fasta_contig.fasta Fairchild_chrUN.fasta_contig_10kb.fasta
sbatch --array 1-9 Step0_prepare_chr.sh
sbatch --array 1-291 Step0_map_bwa_array.sh
sbatch --array 1-644 Step0_map_bwa_array.sh
bash Step1_graph_script.sh

echo "chr7"
mkdir fairchild_graph_57G_chr7_bwa_merge
cp fairchild_graph_57G_chr7_bwa_95_5k_5k/cluster_ori_same_chain_pos_for_seq.txt ./fairchild_graph_57G_chr7_bwa_merge/
sbatch Graph_Assembly_chr7_merge.sh
cp Graph_Assembly_chr7_merge.sh* fairchild_graph_57G_chr7_bwa_merge/
cd fairchild_graph_57G_chr7_bwa_merge
sbatch Step0_map_blasr.sh

