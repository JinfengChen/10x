import os
import sys
import pickle

#PICKLE_FILE= './grocsvs_example/results/WindowBarcodesStep/bcwindows.tumor.10X_tumor.chr1.4.pickle'
PICKLE_FILE=sys.argv[1]

def main():
	for item in read_from_pickle(PICKLE_FILE):
		print(repr(item))

def read_from_pickle(path):
	 with open(path, 'rb') as infile:
		try:
			while True:
				yield pickle.load(infile)
		except EOFError:
			pass

if __name__ == '__main__':
	main()
