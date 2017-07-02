import collections
import gzip
import numpy
import os
import pandas
import pysam
import cStringIO as StringIO
import subprocess

from grocsvs import step
from grocsvs import utilities

class CombineBionanocloudsStep(step.StepChunk):
    @staticmethod
    def get_steps(options):
        for sample, dataset in options.iter_10xdatasets():
            yield CombineBionanocloudsStep(options, sample, dataset)

    def __init__(self, options, sample, dataset):
        self.options = options
        self.sample = sample
        self.dataset = dataset

    def __str__(self):
        return ".".join([self.__class__.__name__,
                         self.sample.name, 
                         self.dataset.id])
        
    def outpaths(self, final):
        directory = self.results_dir if final \
                    else self.working_dir

        readclouds = "readclouds.{}.{}.tsv.gz".format(
            self.sample.name,
            self.dataset.id
            )

        paths = {
            "readclouds": os.path.join(directory, readclouds),
            "index": os.path.join(directory, readclouds+".tbi")

        }

        return paths

    def run(self):
        outpaths = self.outpaths(final=False)

        self.logger.log("Loading read clouds...")

        readclouds = []
        for i, inpath in enumerate(self.get_input_paths()):
            try:
                readclouds.append(pandas.read_table(inpath, compression="gzip"))
            except pandas.io.common.EmptyDataError:
                self.logger.log("No read clouds found in {}; skipping".format(inpath))
        readclouds = pandas.concat(readclouds)


        self.logger.log("Writing readclouds to file...")

        tmp_readclouds_path = outpaths["readclouds"][:-3]
        readclouds.to_csv(tmp_readclouds_path, sep="\t", index=False)

        bgzip = self.options.binary("bgzip")
        bgzip_cmd = "{} {}".format(bgzip, tmp_readclouds_path)
        bgzip_proc = subprocess.Popen(bgzip_cmd, shell=True)
        bgzip_proc.wait()


        self.logger.log("Indexing readclouds file...")
        # define the chrom, start and end columns; and indicate that
        # the first (header) row should be skipped
        tabix = self.options.binary("tabix")
        tabix_cmd = "{} -s 1 -b 2 -e 3 -S 1 {}".format(tabix, outpaths["readclouds"])
        subprocess.check_call(tabix_cmd, shell=True)


    def get_input_paths(self):
        paths = []
        for chrom in self.options.reference.chroms:
            input_step = CallBionanocloudsStep(self.options, self.sample, self.dataset, chrom)
            paths.append(input_step.outpaths(final=True)["readclouds"])

        return paths

class CallBionanocloudsStep(step.StepChunk):
    @staticmethod
    def get_steps(options):
        for sample, dataset in options.iter_10xdatasets():
            for chrom in options.reference.chroms:
                yield CallBionanocloudsStep(
                    options, sample, dataset, chrom)

        
    def __init__(self, options, sample, dataset, chrom):
        self.options = options
        self.sample = sample
        self.dataset = dataset
        self.chrom = chrom


    def __str__(self):
        return ".".join([self.__class__.__name__,
                         self.sample.name, 
                         self.dataset.id,
                         self.chrom])
        
    def outpaths(self, final):
        directory = self.results_dir if final \
                    else self.working_dir

        readclouds = "readclouds.{}.{}.{}.tsv.gz".format(
            self.sample.name,
            self.dataset.id,
            self.chrom
            )

        paths = {
            "readclouds": os.path.join(directory, readclouds)
        }

        return paths

    def run(self):
        outpaths = self.outpaths(final=False)

        self.logger.log("Call bionano read clouds")
        bgzip = 'gzip'
        samplename       = self.sample.name
        bionano_dir_path = self.dataset.bam
        chrom = self.chrom
        
        call_readclouds(bionano_dir_path, chrom, outpaths["readclouds"][:-3], bgzip)

def call_readclouds(bionano_dir_path, chrom, outfile, bgzip):
    xmap='{}/Fairchild.{}_BSSSI_0kb_0labels_contig1.xmap'.format(bionano_dir_path, chrom)
    rmap='{}/Fairchild.{}_BSSSI_0kb_0labels_contig1_r.cmap'.format(bionano_dir_path, chrom)
    qmap='{}/Fairchild.{}_BSSSI_0kb_0labels_contig1_q.cmap'.format(bionano_dir_path, chrom)
    #1       5421    1       170867.5        283580.5        4465.0  117086.0        +       10.61
    xmap_align = numpy.loadtxt(xmap, comments="#", dtype=str)
    qmap_dict  = parse_label_number(qmap)
    ofile = open(outfile, 'w')
    print >> ofile, 'chrom\tstart_pos\tend_pos\tbc\tnum_reads\tobs_len\thap'
    count = 0
    for i in range(len(xmap_align)):
        count += 1
        label_number, molecular_len = qmap_dict[xmap_align[i][1]] 
        print >> ofile, '\t'.join([chrom, xmap_align[i][5], xmap_align[i][6], '{}.{}'.format(chrom, count), label_number, molecular_len, ""])
    ofile.close()
    tmp_readclouds_path = outfile
    bgzip_cmd = "{} {}".format(bgzip, tmp_readclouds_path)
    bgzip_proc = subprocess.Popen(bgzip_cmd, shell=True)
    bgzip_proc.wait()
    

#h CMapId       ContigLength    NumSites        SiteID  LabelChannel    Position        StdDev  Coverage        Occurrence      GmeanSNR        lnSNRsd
#f int  float   int     int     int     float   float   float   float   float   float
#68      410562.9        33      1       1       262.1   0.0     1.0     1.0     11.5581 0.0000
def parse_label_number(qmap):
    data = collections.defaultdict(lambda : list())
    qmap_align = numpy.loadtxt(qmap, comments="#", dtype=str)
    for i in range(len(qmap_align)):
        data[qmap_align[i][0]] = [qmap_align[i][2], qmap_align[i][1]]
    return data
