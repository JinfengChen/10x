git clone https://github.com/grocsvs/grocsvs.git
echo "create virtualenv for grocsvs"
virtualenv grocsvs_env
source grocsvs_env/bin/activate
pip install -U rpy2

#echo "install grocsvs"
#pip install .

echo "install"
#graphviz
pip install graphviz
#ibda
tar -xf 1.1.3g1.tar.gz
cd idba-1.1.3g1
module unload perl/5.20.2
module load perl/5.16.3
./build.sh
./configure --prefix=/rhome/cjinfeng/BigData/00.RD/Assembly/10xgenomics/tools/GROCSVS/bin
make
cd ../bin/
ln -s ~/BigData/00.RD/Assembly/10xgenomics/tools/GROCSVS/idba-1.1.3g1/bin/idba_ud ./
#bwa
ln -s /opt/linux/centos/7.x/x86_64/pkgs/bwa/0.7.15/bin/bwa ./
#samtools
ln -s /opt/linux/centos/7.x/x86_64/pkgs/samtools/1.3/bin/samtools ./
#htslib
ln -s /opt/linux/centos/7.x/x86_64/pkgs/htslib/1.3.1/bin/* ./
#netifaces
cd ~/BigData/software/miniconda2/envs/
conda create --name GROCSVS -c bcbio netifaces=0.10.4
conda install --name GROCSVS pandas==0.19.2
cd -
export PYTHONPATH=$PYTHONPATH:~/BigData/software/pythonlib/pygraphviz/lib/python2.7/site-packages/:/rhome/cjinfeng/BigData/software/miniconda2/envs/GROCSVS/lib/python2.7/site-packages/
export PYTHONPATH=/rhome/cjinfeng/BigData/software/miniconda2/envs/GROCSVS/lib/python2.7/site-packages/:~/BigData/software/pythonlib/pygraphviz/lib/python2.7/site-packages/:$PYTHONPATH
#grocsvs
pip install .

#to run 
export PYTHONPATH=/rhome/cjinfeng/BigData/software/miniconda2/envs/GROCSVS/lib/python2.7/site-packages/:~/BigData/software/pythonlib/pygraphviz/lib/python2.7/site-packages/:$PYTHONPATH
./grocsvs_env/bin/grocsvs
