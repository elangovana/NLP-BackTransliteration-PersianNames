import timeit

import logging
from editdistancematch import editdistancematch

from setup_logger import setup_log
import fuzzy

__author__ = 'aparnaelangovan'

import csv
import os
import numpy as np
import pandas as pd
import time
import ngram

class ngrammatch():
    def __init__(self, out_dir, logger=None, ngram=1):
        self.ngram = ngram
        self.out_dir = out_dir
        self.logger = logger
        self.logger = logger or logging.getLogger(__name__)

    def LogSummary(self):
        self.logger.info("--Summary--")

        self.logger.info("Ngram length Cost" + ":" + str(self.ngram))

        self.logger.info("Accuracy ( scored only when exactly one is correct) = " + str(self.accuracy))
        self.logger.info("Precision = " + str(self.precision))
        self.logger.info("Recall = " + str(self.recall))
        self.logger.info("--End of summary--")

    def calculate_edit_distance(self, dftraindata, dfnames):
        self.logger.info("Train data rows, cols = " + str(dftraindata.shape))

        #pre processing - lowercase
        dftraindata['persianname'] = (dftraindata['persianname'].apply(lambda x: x.lower()))

        #merge df
        dfnames['tmp'] = 1
        dftraindata['tmp'] = 1
        dfmerged = pd.merge(dftraindata, dfnames)

        # calc cost
        start = time.time()
        start = time.time()
        vGetCost = np.vectorize(ngram.NGram.compare, excluded=['N'])
        dfmerged['cost'] =vGetCost (dfmerged['persianname'], dfmerged['name'], N=self.ngram)
        self.logger.info("Time taken(sec) for calculating ngram distance = " + str(time.time() - start))


        # Get max similarity
        start = time.time()
        grpd = dfmerged.groupby(['persianname'], as_index=False).agg({'cost': 'max'})
        self.logger.info("Time taken(sec) for grouping by persian name for min cost= " + str(time.time() - start))

        # Set up result
        start = time.time()
        result = pd.merge(grpd, dfmerged)
        grpd = pd.DataFrame(result.groupby(['persianname'], as_index=False).size().rename('counts'))
        result = pd.merge(result, grpd, left_on=['persianname'], right_index=True)
        self.logger.info(
            "Time taken(sec) for grouping by persian name for counts of results" + str(time.time() - start))

        # Result
        self.totalaccuratelycorrect = \
        (result[(result['counts'] == 1) & (result['englishname'] == result['name'])]).shape[0]
        self.accuracy = float(self.totalaccuratelycorrect) / float(dftraindata.shape[0])
        self.totatcorrect = (result[(result['englishname'] == result['name'])]).shape[0]
        self.precision = float(self.totatcorrect) / float(result.shape[0])
        self.recall = float(self.totatcorrect) / float(dftraindata.shape[0])
        self.result = result;
        self.result.to_csv(os.path.join(self.out_dir, "persiansnamespredicted.csv"))

        self.LogSummary()
        print("Accuracy = " + str(self.accuracy))
        print("Precision = " + str(self.precision))
        print("Recall = " + str(self.recall))






