#!/usr/bin/python
import sys
from collections import defaultdict
import numpy as np
import re
import os
import argparse
import glob
from Bio import SeqIO
sys.path.append('/rhome/cjinfeng/BigData/software/ProgramPython/lib')
from utility import gff_parser, createdir

def usage():
    test="name"
    message='''
python scripts/pool_reads_asm.py --input test.fq_split

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

def write_slurm_shell_canu(fa_dir):
    shell = '%s.canu.sh' %(fa_dir)
    cmd='''#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --mem=100G
#SBATCH --time=40:00:00
#SBATCH --output=%s.stdout
#SBATCH -p intel
#SBATCH --workdir=./

#run assembly with canu: all in 1
module load java/8u25
canu=/rhome/cjinfeng/BigData/00.RD/Assembly/Pacbio/install/Canu/canu-1.3/Linux-amd64/bin/canu

CPU=$SLURM_NTASKS
if [ ! $CPU ]; then
   CPU=2
fi

N=$SLURM_ARRAY_TASK_ID
if [ ! $N ]; then
    N=1
fi

echo "CPU: $CPU"
echo "N: $N"

fasta=`ls %s/*.pacbio_reads.fa | head -n $N | tail -n 1`

if [ ! -e $fasta\_canu ]; then
 echo "canu assembly: $fasta"
 $canu -assemble \\
     maxMemory=90 \\
     maxThreads=$CPU \\
     useGrid=false \\
     -p citrus -d $fasta\_canu \\
     genomeSize=70m \\
     -pacbio-corrected $fasta
fi
echo "Done"
''' %(shell, fa_dir)

    ofile = open(shell, 'w')
    print >> ofile, cmd
    ofile.close()
    #if not os.path.exists('%s_canu' %(fa)):
    job = 'sbatch --array 1-54 %s.canu.sh' %(fa_dir)
    print job
    #os.system(job)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input')
    parser.add_argument('-c', '--cpu', default='24')
    parser.add_argument('-v', dest='verbose', action='store_true')
    args = parser.parse_args()
    try:
        len(args.input) > 0
    except:
        usage()
        sys.exit(2)
    
    if args.input:
        args.input = os.path.abspath(args.input)   

    write_slurm_shell_canu(args.input)        


if __name__ == '__main__':
    main()

