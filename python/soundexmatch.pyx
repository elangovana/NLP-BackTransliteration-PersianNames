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
        # dftraindata["predicted.englishname"]=dftraindata.apply(lambda r: "a",axis=1 )
        # dftraindata["bestmatchcount"]=dftraindata.apply(lambda r: 0,axis=1  )
        # dftraindata["bestcost"]=dftraindata.apply(lambda r: 1000,axis=1  )

        dfnames['tmp']=1
        dftraindata['tmp']=1
        dftraindata['persianname']=(dftraindata['persianname'].apply(lambda x: x.lower()))
        soundex = fuzzy.Soundex(4)
        dftraindata['persiannamesoundex'] = (dftraindata['persianname'].apply(lambda x:soundex(x)))
        dfnames['namesoundex'] = (dfnames['name'].apply(lambda x: soundex(x)))


        dfmerged = pd.merge(dftraindata,dfnames )


        #calc cost
        start = time.time()
        vGetWeightedDistance = np.vectorize(self.GetWeightedDistance)
        dfmerged['cost']=vGetWeightedDistance(dfmerged['persiannamesoundex'], dfmerged['namesoundex'])
        self.logger.info ("Time taken(sec) for calculating edit distance = " + str( time.time() - start))



        #calc cost
        # start = time.time()
        # dfmerged['cost']=dfmerged.apply(lambda x: self.GetWeightedDistance(x['persianname'], x['name']),axis=1 )
        #
        # end = time.time()
        # print ("time for cost")
        # print(end - start)

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

        #dftraindata=dftraindata[0:5]
        #calc
        # start = time.time()
        # self.method_name_old_style(dfnames, dftraindata)
        # print(time.time() - start)

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



