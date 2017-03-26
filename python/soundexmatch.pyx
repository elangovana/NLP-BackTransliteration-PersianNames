import timeit

import logging

import utilities
from editdistancematch import editdistancematch

from setup_logger import setup_log
import fuzzy

__author__ = 'aparnaelangovan'

import csv
import os
import numpy as np
from weighted_levenshtein import lev, osa, dam_lev
import pandas as pd
import time

class soundexmatch(editdistancematch):
    def __init__(self, out_dir, logger=None, insert_cost =1, delete_cost=1, substitute_cost=1):
        editdistancematch.__init__(self, out_dir, logger, insert_cost, delete_cost, substitute_cost)


    def calculate_edit_distance(self, dftraindata, dfnames):

        self.logger.info ("Train data rows, cols = " +str(dftraindata.shape))

        # pre processing - lowercase
        dftraindata['persianname']=(dftraindata['persianname'].apply(lambda x: x.lower()))

        #obtain soundex
        start = time.time()
        soundex = fuzzy.Soundex(4)
        dftraindata['persiannamesoundex'] = (dftraindata['persianname'].apply(lambda x:soundex(x)))
        dfnames['namesoundex'] = (dfnames['name'].apply(lambda x: soundex(x)))
        self.logger.info("Time taken(sec) for calculating soundex" + str(time.time() - start))

        #set up merged df
        dfnames['tmp']=1
        dftraindata['tmp']=1
        dfmerged = pd.merge(dftraindata,dfnames )


        #calc cost
        start = time.time()
        vGetWeightedDistance = np.vectorize(self.GetWeightedDistance)
        dfmerged['cost']=vGetWeightedDistance(dfmerged['persiannamesoundex'], dfmerged['namesoundex'])
        self.logger.info ("Time taken(sec) for calculating edit distance = " + str( time.time() - start))

        #Get min cost
        start = time.time()
        grpd = dfmerged.groupby(['persianname'] ,as_index = False).agg({'cost':'min'})
        self.logger.info ("Time taken(sec) for grouping by persian name for min cost= " + str(time.time() - start))

        # Set up result
        start = time.time()
        result=pd.merge(grpd,dfmerged )
        grpd=pd.DataFrame(result.groupby(['persianname'], as_index=False).size().rename('counts'))
        result=pd.merge(result,grpd ,left_on=['persianname'], right_index=True)
        self.logger.info("Time taken(sec) for grouping by persian name for counts of results" + str(time.time() - start))


        #Result
        self.totalaccuratelycorrect=(result[(result['counts'] == 1) & (result['englishname'] == result['name'])]).shape[0]
        self.accuracy= float(self.totalaccuratelycorrect) / float(dftraindata.shape[0])
        self.totatcorrect=(result[(result['englishname'] == result['name'])]).shape[0]
        self.precision = float(self.totatcorrect) / float(result.shape[0])
        self.recall = float(self.totatcorrect) / float(dftraindata.shape[0])
        self.result = result;
        self.result.to_csv(os.path.join(self.out_dir,"persiansnamespredicted.csv"))

        self.LogSummary()
        print("Accuracy = " + str(self.accuracy))
        print("Precision = " + str(self.precision))
        print("Recall = " + str(self.recall))



