__author__ = 'aparnaelangovan'
import time
import pandas as pd
from setup_logger import setup_log
import persiannames
import os


dir = os.path.dirname(__file__)
out_dir=os.path.join(os.path.dirname(__file__),"../outputdata/train_{}".format(time.strftime('%Y%m%d_%H%M%S')))
os.makedirs(out_dir)

logger = setup_log(out_dir)


traindatacsv=os.path.join(dir,"../input_data/train.txt")
namesdict=os.path.join(dir,"../input_data/names.txt")
dftraindata = pd.read_csv(traindatacsv, sep='\t', header=None, names=["persianname", "englishname"], dtype=object)
dfnames = pd.read_csv(namesdict, sep='\t', header=None, names=["name"], keep_default_na=False)

dftraindata = dftraindata.sample(1000)


##run 1
resultsdir=os.path.join(out_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
os.makedirs(resultsdir)
parser= persiannames.persiannames(resultsdir,logger, insert_cost =1, delete_cost=1, substitute_cost=1)
parser.calculate_edit_distance(dftraindata, dfnames)

##run 2
resultsdir=os.path.join(out_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
os.makedirs(resultsdir)
parser= persiannames.persiannames(resultsdir,logger, insert_cost =1, delete_cost=3, substitute_cost=2)
parser.calculate_edit_distance(dftraindata, dfnames)

##run with weighted replacement cost
resultsdir=os.path.join(out_dir,"Run_{}".format(time.strftime('%Y%m%d_%H%M%S')))
os.makedirs(resultsdir)
parser= persiannames.persiannames(resultsdir,logger, insert_cost =1, delete_cost=2, substitute_cost=1)
parser.set_substitution_cost('a', 'e', .1)
parser.set_substitution_cost('e', 'i', .1)
parser.set_substitution_cost('a', 'o', .2)
parser.set_substitution_cost('o', 'a', .2)
parser.set_substitution_cost('p', 'f', .1)
parser.set_substitution_cost('c', 'k', .1)
parser.set_substitution_cost('k', 'x', .1)
parser.set_substitution_cost('i', 'y', .1)
parser.set_substitution_cost('y', 'e', .1)
parser.set_substitution_cost('v', 'u', .1)
parser.set_substitution_cost('z', 's', .1)
parser.set_insert_cost('a',.1)
parser.set_insert_cost('e',.1)
parser.set_insert_cost('o',.1)
parser.calculate_edit_distance(dftraindata, dfnames)


