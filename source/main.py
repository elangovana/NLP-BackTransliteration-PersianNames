
__author__ = 'aparnaelangovan'

import getopt
import sys
from editdistancematch import editdistancematch
from ngrammatch import ngrammatch
from soundexmatch import soundexmatch
import time
import pandas as pd
from setup_logger import setup_log
import os


def SetUpSubstitutionMatrix(parser):
    parser.set_substitution_cost('a', 'e', .1)
    parser.set_substitution_cost('e', 'i', .1)
    parser.set_substitution_cost('a', 'o', .2)
    parser.set_substitution_cost('o', 'a', .2)
    parser.set_substitution_cost('p', 'f', .1)
    parser.set_substitution_cost('k', 'c', .1)
    parser.set_substitution_cost('k', 'x', .1)
    parser.set_substitution_cost('x', 'k', .1)
    parser.set_substitution_cost('y', 'i', .1)
    parser.set_substitution_cost('y', 'e', .1)
    parser.set_substitution_cost('v', 'u', .1)
    parser.set_substitution_cost('v', 'o', .1)
    parser.set_substitution_cost('v', 'w', .1)
    parser.set_substitution_cost('z', 's', .1)
    parser.set_substitution_cost('z', 'j', .2)
    parser.set_substitution_cost('s', 'c', .4)
    parser.set_substitution_cost('\'', 'a', .1)


def SetupInsertCostMatrix(parser):
    parser.set_insert_cost('a', .01)
    parser.set_insert_cost('e', .01)
    parser.set_insert_cost('i', .01)
    parser.set_insert_cost('o', .01)
    parser.set_insert_cost('u', .01)
    parser.set_insert_cost('h', .02)
    # parser.set_insert_cost('y', .2)
    # parser.set_insert_cost('w', .2)
    # parser.set_insert_cost('v', .2)

def SetupInsertCostMatrix2(parser):
    parser.set_insert_cost('a', .1)
    parser.set_insert_cost('e', .1)
    parser.set_insert_cost('i', .1)
    parser.set_insert_cost('o', .1)
    parser.set_insert_cost('u', .1)
    parser.set_insert_cost('h', .2)

def Process(traindatacsv, namesdictionary, output_dir, samplesize=2000 ):

    traindatacsv=os.path.join(os.path.dirname(__file__),traindatacsv)
    namesdict = os.path.join(os.path.dirname(__file__), namesdictionary)
    output_dir=os.path.join(os.path.dirname(__file__),output_dir)

    os.makedirs(output_dir)
    logger = setup_log(output_dir)

    #load dataframe
    dftraindataO = pd.read_csv(traindatacsv, sep='\t', header=None, names=["persianname", "englishname"], dtype=object)
    dfnamesO = pd.read_csv(namesdict, sep='\t', header=None, names=["name"], keep_default_na=False)

    if (samplesize > 0) :
        dftraindataO = dftraindataO.sample(samplesize)


    ##run 1
    logger.info("----Running 1 editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=1, substitute_cost=1)")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=1, substitute_cost=1)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())

    ##run 2
    logger.info("----Running 2 editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=3, substitute_cost=2)")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=3, substitute_cost=2)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())


    ##run 3.0 with weighted replacement cost
    logger.info("----Running 3 with weighted replacement cost editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=2, substitute_cost=1)")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=2, substitute_cost=1)
    SetUpSubstitutionMatrix(parser)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())


    ##run 4 with weighted replacement cost
    logger.info("----Running 4 with weighted replacement cost editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=3, substitute_cost=2)")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=3, substitute_cost=2)
    SetUpSubstitutionMatrix(parser)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())


    # ##run 5 with weighted replacement  + insert cost cost
    logger.info(
        "----Running 5 with weighted replacement cost ")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=2, substitute_cost=1)
    SetupInsertCostMatrix(parser)
    SetUpSubstitutionMatrix(parser)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())

    # ##run 6 with weighted replacement  + insert cost cost
    logger.info("----Running 6--")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= editdistancematch(resultsdir, logger, insert_cost =1, delete_cost=3, substitute_cost=2)
    SetupInsertCostMatrix(parser)
    SetUpSubstitutionMatrix(parser)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())

    # ##run 6 with weighted replacement  + insert cost cost
    logger.info("----Running 7--")
    resultsdir = os.path.join(output_dir, "Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser = editdistancematch(resultsdir, logger, insert_cost=1, delete_cost=3, substitute_cost=2)
    SetupInsertCostMatrix2(parser)
    SetUpSubstitutionMatrix(parser)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())

    ##run  7 soundexpredictor
    logger.info("----Running 8--")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= soundexmatch(resultsdir,logger, insert_cost =1, delete_cost=1, substitute_cost=1)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())

    ##run  8 ngram = 1
    logger.info("----Running 9--")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= ngrammatch(resultsdir,logger, ngram=1)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())

    ##run 9 ngram = 2
    logger.info("----Running 10--")
    resultsdir=os.path.join(output_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
    os.makedirs(resultsdir)
    parser= ngrammatch(resultsdir,logger, ngram=2)
    parser.calculate_edit_distance(dftraindataO.copy(), dfnamesO.copy())


def main(argv):
    inputfile="../input_data/train.txt"
    namesDict="../input_data/names.txt"
    outdir="../output/train_{}".format(time.strftime('%Y%m%d_%H%M%S'))
    samplesize=0
    try:
        opts, args = getopt.getopt(argv, "hi:n:o:s", ["ifile=", "nfile=","outdir=" ,"samplesize="])
    except getopt.GetoptError:
        print 'main.py -i <inputfile> -n <namesdictionaryfile> -o <outputdir>  [-s  <samplesize>]'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print '-i <inputfile> -n <namesdictionaryfile> -o <outputdir> [ -s  <samplesize>]'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            inputfile = arg
        elif opt in ("-o", "--outdir"):
            outdir = arg
        elif opt in ("-n", "--nfile"):
            namesDict = arg
        elif opt in ("-s", "--samplesize"):
            samplesize = int(arg)
    Process(inputfile, namesDict, outdir, samplesize)


if __name__ == "__main__":
   main(sys.argv[1:])