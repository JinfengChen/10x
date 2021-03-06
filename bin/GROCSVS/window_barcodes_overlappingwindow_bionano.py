import numpy
import os

from grocsvs import datasets as svdatasets
from grocsvs import step
from grocsvs import utilities
from grocsvs.stages import call_readclouds
from grocsvs.stages import call_bionano_clouds 

CHUNKSIZE = 5e7

def chunks_for_chrom(options, chrom):
    return int(numpy.ceil(options.reference.chrom_lengths[chrom]/CHUNKSIZE))


class WindowBarcodesStep(step.StepChunk):
    """
    Build a list of all the fragment barcodes overlapping each
    genomic window

    Output files:
        bcwindows.sample.dataset.chrom.pickle - dictionary:
        - barcode_windows - a list of sets of barcode IDs
        - barcod_map - a dict of barcode->barcode ID
        - window_size - the size of the genomic window used; eg 10,000 would 
            mean that window starts were range(0, chrom_length, 10000)
    """

    @staticmethod
    def get_steps(options):
        for sample, dataset in options.iter_10xdatasets():
            for chrom in options.reference.chroms:
                for chunk in range(chunks_for_chrom(options, chrom)):
                    yield WindowBarcodesStep(
                        options, sample, dataset, chrom, chunk)

    def __init__(self, options, sample, dataset, chrom, chunk):
        self.options = options
        self.sample = sample
        self.dataset = dataset
        self.chrom = chrom
        self.chunk = chunk

        assert isinstance(self.dataset, svdatasets.TenXDataset)


    def __str__(self):
        return ".".join([self.__class__.__name__,
                         self.sample.name, 
                         self.dataset.id, 
                         self.chrom,
                         str(self.chunk)])
        
    def outpaths(self, final):
        directory = self.results_dir if final \
                    else self.working_dir

        file_name = "bcwindows.{}.{}.{}.{}.pickle".format(
            self.sample.name,
            self.dataset.id,
            self.chrom,
            self.chunk)

        paths = {
            "bcwindows": os.path.join(directory, file_name)
        }

        return paths

        
    def outpaths_2(self, final, pos):
        directory = self.results_dir if final \
                    else self.working_dir

        file_name = "bcwindows.{}.{}.{}.{}.{}.pickle".format(
            self.sample.name,
            self.dataset.id,
            self.chrom,
            self.chunk,
            pos)

        paths = {
            "bcwindows": os.path.join(directory, file_name)
        }

        return paths

    def run(self):
        import logging
        logging.info("running!")

        window_size = self.options.constants["window_size"]
        #walk by 100bp, we generate two windows up and down stream of one point, compare barcode from these two window to get similarity level of this point
        walk_step   = 1000
        outpath     =  self.outpaths(final=False)["bcwindows"]

        self.logger.log("Loading barcode map...")
        # call_readclouds_step = call_readclouds.FilterFragmentsStep(
        input_step = call_bionano_clouds.CombineBionanocloudsStep(
            self.options, self.sample, self.dataset)
        barcode_map = utilities.pickle.load(
            open(input_step.outpaths(final=True)["barcode_map"]))

        chrom_length = self.options.reference.chrom_lengths[self.chrom]
        start = int(self.chunk*CHUNKSIZE)
        end = int(min((self.chunk+1)*CHUNKSIZE, chrom_length))


        self.logger.log("Running chunk: {}:{:,}-{:,}".format(self.chrom, start, end))

        fragments = call_bionano_clouds.load_fragments(
            self.options, self.sample, self.dataset,
            self.chrom, start, end, min_reads_per_frag=0)

        #barcode_windows = get_barcode_windows(
        #    fragments, barcode_map, window_size, chrom_length, start, end)
        barcode_windows  = get_barcode_windows_seperate(fragments, barcode_map, window_size, chrom_length, start, end, walk_step)


        self.logger.log("Saving results...")
        result = {
            "barcode_windows": barcode_windows,
            # "barcode_map":     barcode_map,
            "nbcs": len(barcode_map),
            "window_size":     window_size
        }
        utilities.pickle.dump(result, open(outpath, "w"), protocol=-1)


def get_barcode_windows(fragments, barcode_map, window_size, chrom_length, start, end):
    window_starts = range(start, end, window_size)

    barcode_windows = []

    for start in window_starts:
        end = start + window_size
        overlap = utilities.frags_overlap_same_chrom(fragments, start, end)
        barcodes = set(barcode_map[bc] for bc in overlap["bc"])
        barcode_windows.append(barcodes)

    return barcode_windows

#get barcode windows for up and downstream from each position seperately
def get_barcode_windows_seperate(fragments, barcode_map, window_size, chrom_length, start, end, walk_step):
    window_starts = range(start, end-2*window_size, walk_step)
    barcode_windows = []
   
    for start in window_starts:
        #up windows
        end = start + window_size
        overlap = utilities.frags_overlap_same_chrom(fragments, start, end)
        barcodes = set(barcode_map[bc] for bc in overlap["bc"])
        barcode_windows.append(barcodes)
        barcode_windows.append(set([start, end]))
        #down windows, need to change the start by start + windows size
        start1 = start + window_size + 1
        end1 = start1 + window_size
        overlap1 = utilities.frags_overlap_same_chrom(fragments, start1, end1)
        barcodes1 = set(barcode_map[bc1] for bc1 in overlap1["bc"])
        barcode_windows.append(barcodes1)
        barcode_windows.append(set([start1, end1]))

    return barcode_windows 

