#!/opt/Python/2.7.3/bin/python
import sys
from collections import defaultdict
import numpy as np
import re
import os
import argparse
import glob
import h5py
from Bio import SeqIO
sys.path.append('/rhome/cjinfeng/BigData/software/ProgramPython/lib')
from utility import gff_parser, createdir

def usage():
    test="name"
    message='''
python Plot_Region_similarity.py --input test.list


    '''
    print message


def runjob(script, lines):
    cmd = 'perl /rhome/cjinfeng/BigData/software/bin/qsub-slurm.pl --maxjob 60 --lines 2 --interval 120 --task 1 --mem 15G --time 100:00:00 --convert no %s' %(lines, script)
    #print cmd 
    os.system(cmd)



def fasta_id(fastafile):
    fastaid = defaultdict(str)
    for record in SeqIO.parse(fastafile,"fasta"):
        fastaid[record.id] = 1
    return fastaid


def readtable(infile):
    data = defaultdict(str)
    with open (infile, 'r') as filehd:
        for line in filehd:
            line = line.rstrip()
            if len(line) > 2: 
                unit = re.split(r'\t',line)
                if not data.has_key(unit[0]):
                    data[unit[0]] = unit[1]
    return data

def parse_hd5_file(infile, ofile):
    outfile = open(ofile, 'w')
    table = h5py.File(infile, 'r')
    ks    = table.keys()
    r = re.compile(r'bcoverlaps\.map\.bionano')
    cutoff = 50
    if r.search(infile):
        cutoff = 20
    for index, key in enumerate(ks):
        print index, key
        data = table[key][:]
        for x in data:
            x = list(x)
            sim = 'NA'
            if x[1] > 50 and x[2] > 50:
                sim = float(x[0])/min(x[1], x[2])
            x.insert(1, sim)
            print >> outfile, '\t'.join(map(str, x))
    outfile.close()
    return ofile

def plot_curve(table_10x, table_map, prefix, left, right):
    
    R_cmd='''
pdf("%s.similiarity_curve.pdf", height=3, width=12)
par(mar=c(5,5,4,2))
read.table("%s", header=FALSE) -> x
read.table("%s", header=FALSE) -> y
left  <- %s
right <- %s
bin <- (right-left)/10
if (left+10*bin > right){
   right <- left+10*bin
}
x <- x[(x[,7] > left*1000000 & x[,7] < right*1000000),]
y <- y[(y[,7] > left*1000000 & y[,7] < right*1000000),]
atxvalue <- seq (left, right, by=bin)
atyvalue <- c(0, 0.5, 1)
atx <- c(atxvalue*1000000)
aty <- c(atyvalue)
plot(x[,7], x[,2], type="p", pch=5, cex=0.5, col="blue", xlab="Position (Mb)", ylab="Read cloud similarity", xlim=c(left*1000000, right*1000000), ylim=c(0, 1), axes=FALSE, cex.lab=1.4)
lines(y[,7], y[,2], type="p", pch=4, cex=0.5, col="red")
axis(1, at=atx, labels=atxvalue, cex.lab=1.4, cex.axis=1.4, cex.sub=1.4, cex.main=1.4, cex=1.4)
axis(2, at=aty, labels=aty, cex.lab=1.4, cex.axis=1.4, cex.sub=1.4, cex.main=1.4, cex=1.4)
par(xpd=TRUE)
legend((right-4*bin)*1000000, 1.5, c("10x Genomics","bionano"), bty="n", pch=c(5,4), border="NA", lty=c(1,1), cex=1.4, col=c("blue","red"), ncol = 2, xpd=TRUE)
#legend("topleft", c("10x Genomics","bionano"), bty="n", pch=c(5,4), border="NA", lty=c(1,1), cex=1.4, col=c("blue","red"), ncol = 2, xpd=TRUE)
dev.off()
''' %(prefix, table_10x, table_map, left, right)
    np.savetxt('%s.test.R' %(prefix), np.array(R_cmd).reshape(1,), fmt='%s') 
    os.system('cat %s.test.R | R --slave' %(prefix))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input')
    parser.add_argument('-o', '--output')
    parser.add_argument('-v', dest='verbose', action='store_true')
    args = parser.parse_args()
    try:
        len(args.input) > 0
    except:
        usage()
        sys.exit(2)

    with open (args.input, 'r') as filehd:
        for line in filehd:
            line = line.rstrip()
            if len(line) > 2: 
                unit = re.split(r'\t',line)
                prefix = '%s_%s_%s' %(unit[0], unit[1], unit[2])
                hdf5_10x   = unit[3]
                hdf5_map   = unit[4]
                left   = unit[1]
                right  = unit[2]
                ofile_10x = '%s.table' %(hdf5_10x)
                ofile_map = '%s.table' %(hdf5_map)
                if not os.path.exists(ofile_10x):
                    parse_hd5_file(hdf5_10x, ofile_10x)
                if not os.path.exists(ofile_map):
                    parse_hd5_file(hdf5_map, ofile_map)
                plot_curve(ofile_10x, ofile_map, prefix, left, right)

if __name__ == '__main__':
    main()

