echo "run SV by grocsvs"
sbatch grocsvs.sh

echo "run region similarity by grocsvs_asm"
sbatch grocsvs_asm.sh
#add bionano
cp call_bionano_clouds.py /bigdata/stajichlab/cjinfeng/00.RD/Assembly/10xgenomics/tools/GROCSVS/GROCSVS_asm/grocsvs/grocsvs_env/lib/python2.7/site-packages/grocsvs/stages/call_bionano_clouds.py
cp Region_10x_similarity.py /bigdata/stajichlab/cjinfeng/00.RD/Assembly/10xgenomics/tools/GROCSVS/GROCSVS_asm/grocsvs/grocsvs_env/lib/python2.7/site-packages/grocsvs/main.py
cp window_barcodes_overlappingwindow.py /bigdata/stajichlab/cjinfeng/00.RD/Assembly/10xgenomics/tools/GROCSVS/GROCSVS_asm/grocsvs/grocsvs_env/lib/python2.7/site-packages/grocsvs/stages/
cp barcode_overlaps_overlappingwindow.py /bigdata/stajichlab/cjinfeng/00.RD/Assembly/10xgenomics/tools/GROCSVS/GROCSVS_asm/grocsvs/grocsvs_env/lib/python2.7/site-packages/grocsvs/stages/
sbatch grocsvs_asm.sh

#python Plot_Region_similarity.py --input grocsvs_fairchild/results/BarcodeOverlapsStep/bcoverlaps.tumor.10X_fairchild.chr3.chr3.0.0.hdf5
python Plot_Region_similarity.py --input test.list
python Plot_Region_similarity.py --input FCM_CLM_compare.list
