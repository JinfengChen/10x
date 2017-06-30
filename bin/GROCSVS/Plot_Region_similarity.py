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
python CircosConf.py --input circos.config --output pipe.conf

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

def plot_curve(table, prefix):
    
    R_cmd='''
pdf("%s.similiarity_curve.pdf", height=4, width=12)
read.table("%s", header=FALSE) -> x
x <- x[(x[,7] > 28000000 & x[,7] < 40000000),]
atxvalue <- seq (28, 40, by=2)
atyvalue <- seq (0, 1, by=0.2)
atx <- c(atxvalue*1000000)
aty <- c(atyvalue)
plot(x[,7], x[,2], type="p", pch=18, col="blue", xlab="Position (Mb)", ylab="Read cloud similarity", xlim=c(28*1000000, 40*1000000), ylim=c(0, 1), axes=FALSE)
axis(1, at=atx, labels=atxvalue)
axis(2, at=aty, labels=aty)
dev.off()
''' %(prefix, table)
    np.savetxt('%s.test.R' %(prefix), np.array(R_cmd).reshape(1,), fmt='%s') 

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

    ofile = '%s.table' %(args.input)
    if not os.path.exists(ofile):
        parse_hd5_file(args.input, ofile)
    plot_curve(ofile, 'chr3_28_40')

if __name__ == '__main__':
    main()

