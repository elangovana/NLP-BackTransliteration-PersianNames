import timeit

import logging
from setup_logger import setup_log

__author__ = 'aparnaelangovan'

import csv
import os
import numpy as np
from weighted_levenshtein import lev, osa, dam_lev
import pandas as pd
import time

class editdistancematch:
    def __init__(self, out_dir, logger=None, insert_cost =1, delete_cost=1, substitute_cost=1):
        self.substitute_cost = substitute_cost
        self.delete_cost = delete_cost
        self.insert_cost = insert_cost
        self.out_dir = out_dir
        self.logger = logger
        self.logger = logger or logging.getLogger(__name__)
        # setup
        self.SetupCostMatrix()

    def SetupCostMatrix(self):
        self.insert_matrix_costs = np.full(128, self.insert_cost, dtype=np.float64)  # make an array of all 1's of size 128, the number of ASCII characters

        self.delete_matrix_costs = np.full(128, self.delete_cost, dtype=np.float64)

        self.substitute_matrix_costs = np.full((128, 128), self.substitute_cost, dtype=np.float64)  # make a 2D array of 1's

    def LogSummary(self):
        self.logger.info("--Summary--")
        self.logger.info("Substitution cost :" + str(self.substitute_cost))
        self.logger.info("Delete cost" +":" + str(self.delete_cost))
        self.logger.info("Insert Cost" + ":" + str(self.insert_cost))
        self.logger.debug("Substitution matrix")
        self.logger.debug(np.matrix(self.substitute_matrix_costs))
        self.logger.debug("Insert matrix")
        self.logger.debug(np.matrix(self.insert_matrix_costs))
        self.logger.debug("Delete matrix")
        self.logger.debug(np.matrix(self.delete_matrix_costs))
        self.logger.info("Accuracy ( scored only when exactly one is correct) = " + str(self.accuracy))
        self.logger.info("Precision = " + str(self.precision))
        self.logger.info("Recall = " + str(self.recall))
        self.logger.info("--End of summary--")



    def calculate_edit_distance(self, dftraindata, dfnames):

        self.logger.info ("Train data rows, cols = " +str(dftraindata.shape))

        #pre-process lower names
        dftraindata['persianname'] = (dftraindata['persianname'].apply(lambda x: x.lower()))

        #merge df
        dfnames['tmp']=1
        dftraindata['tmp']=1
        dfmerged = pd.merge(dftraindata,dfnames )


        #calc cost
        start = time.time()
        vGetWeightedDistance = np.vectorize(self.GetWeightedDistance)
        dfmerged['cost']=vGetWeightedDistance(dfmerged['persianname'], dfmerged['name'])
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



    def GetWeightedDistance(self, source, dest):
        return lev(source, dest, insert_costs=self.insert_matrix_costs, delete_costs=self.delete_matrix_costs, substitute_costs=self.substitute_matrix_costs)  # now it prints '1.25'


    def set_substitution_cost(self, char1, char2, cost):
        self.logger.info("Setting substitution cost {} for character {}, {}".format(cost, char1, char2))
        self.substitute_matrix_costs[ord(char1), ord(char2)] = cost


    def set_insert_cost(self, char1,  cost):
        self.logger.info("Setting insert cost {} for character {}".format(cost, char1,))
        self.insert_matrix_costs[ord(char1)] =cost