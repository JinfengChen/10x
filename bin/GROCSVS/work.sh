echo "run SV by grocsvs"
sbatch grocsvs.sh

echo "run region similarity by grocsvs_asm"
sbatch grocsvs_asm.sh
python Plot_Region_similarity.py --input grocsvs_fairchild/results/BarcodeOverlapsStep/bcoverlaps.tumor.10X_fairchild.chr3.chr3.0.0.hdf5

