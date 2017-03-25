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
parser= persiannames.persiannames(out_dir,logger)

traindatacsv=os.path.join(dir,"../input_data/train.txt")
namesdict=os.path.join(dir,"../input_data/names.txt")
dftraindata = pd.read_csv(traindatacsv, sep='\t', header=None, names=["persianname", "englishname"], dtype=object)
dfnames = pd.read_csv(namesdict, sep='\t', header=None, names=["name"], keep_default_na=False)

dftraindata = dftraindata[1:1000]

parser.set_substitution_cost('a', 'e', .1)
parser.set_substitution_cost('a', 'o', .2)
parser.set_substitution_cost('p', 'f', .1)
parser.set_substitution_cost('c', 'k', .1)
parser.set_substitution_cost('k', 'x', .1)
parser.set_substitution_cost('i', 'y', .1)
parser.set_substitution_cost('y', 'e', .1)
parser.set_substitution_cost('v', 'u', .1)

parser.calculate_edit_distance(dftraindata, dfnames)


