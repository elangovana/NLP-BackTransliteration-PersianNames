import timeit


__author__ = 'aparnaelangovan'

import csv
import os
import numpy as np
from weighted_levenshtein import lev, osa, dam_lev
import pandas as pd
import time

class persiannames:

    def SetupBlosumMatrix(self):
        self.insert_costs = np.ones(128, dtype=np.float64)  # make an array of all 1's of size 128, the number of ASCII characters
        # insert_costs[ord('D')] = 1.5  # make inserting the character 'D' have cost 1.5 (instead of 1)

        # you can just specify the insertion costs
        # delete_costs and substitute_costs default to 1 for all characters if unspecified
        # print lev(source, dest, insert_costs=insert_costs)  # prints '1.5'

        self.delete_costs = np.ones(128, dtype=np.float64)
        # delete_costs[ord('S')] = 0.5  # make deleting the character 'S' have cost 0.5 (instead of 1)

        # or you can specify both insertion and deletion costs (though in this case insertion costs don't matter)
        # print lev(source, dest, insert_costs=insert_costs, delete_costs=delete_costs)  # prints '0.5'


        self.substitute_costs = np.ones((128, 128), dtype=np.float64)  # make a 2D array of 1's
        # substitute_costs[ord('H'), ord('B')] = 1.25  # make substituting 'H' for 'B' cost 1.25

    def load(self, traindatacsv, namesdict):
        dftraindata=pd.read_csv(traindatacsv, sep='\t',header=None, names=["persianname","englishname"],dtype=object )
        dfnames=pd.read_csv(namesdict, sep='\t',header=None, names=["name"], keep_default_na=False )
        dftraindata= dftraindata[1:100]
        print (dftraindata.shape)
        # dftraindata["predicted.englishname"]=dftraindata.apply(lambda r: "a",axis=1 )
        # dftraindata["bestmatchcount"]=dftraindata.apply(lambda r: 0,axis=1  )
        # dftraindata["bestcost"]=dftraindata.apply(lambda r: 1000,axis=1  )

        print(time.time())
        dfnames['tmp']=1
        dftraindata['tmp']=1
        dftraindata['persianname']=(dftraindata['persianname'].apply(lambda x: x.lower()))

        start = time.time()


        dfmerged = pd.merge(dftraindata,dfnames )

        end = time.time()
        print ("merge time for cost")
        print(end - start)

        #setup
        self.SetupBlosumMatrix()

        #calc cost
        start = time.time()
        vGetWeightedDistance = np.vectorize(self.GetWeightedDistance)
        dfmerged['cost']=vGetWeightedDistance(dfmerged['persianname'], dfmerged['name'])
        end = time.time()
        print ("time for cost with vector")
        print(end - start)


        #calc cost
        # start = time.time()
        # dfmerged['cost']=dfmerged.apply(lambda x: self.GetWeightedDistance(x['persianname'], x['name']),axis=1 )
        #
        # end = time.time()
        # print ("time for cost")
        # print(end - start)

        #group
        start = time.time()
        grpd = dfmerged.groupby(['persianname'] ,as_index = False).agg({'cost':'min'})
        # print (grpd)
        # grpd = grpd.groupby(['persianname'],as_index = False).agg(['count'])
        end = time.time()
        print ("time for group")
        print(end - start)


        result=pd.merge(grpd,dfmerged )

        grpd=pd.DataFrame(result.groupby(['persianname'], as_index=False).size().rename('counts'))

        result=pd.merge(result,grpd ,left_on=['persianname'], right_index=True)

        #dftraindata=dftraindata[0:5]
        #calc
        # start = time.time()
        # self.method_name_old_style(dfnames, dftraindata)
        # print(time.time() - start)

        self.totalcorrect=(result[(result['counts']==1) & (result['englishname']==result['name'])]).shape[0]
        self.accuracy=float(self.totalcorrect)/float(dftraindata.shape[0])
        self.result = result;
        print(self.totalcorrect)

        print(float(dftraindata.shape[0]))
        print(self.accuracy)
        print(self.result)



    def method_name_old_style(self, dfnames, dftraindata):
        i = 0;
        # bestMatch = lambda r, n:  self.GetWeightedDistance(r["persionname"], n)
        for ni, nr in dfnames.iterrows():
            pass
            i = 1 + i

            cost = dftraindata['persianname'].apply(
                lambda x: self.GetWeightedDistance(x.lower(), nr['name'].lower()))
            # print (cost)
            # dftraindata["predicted.englishname"] = np.where(cost[0] < dftraindata["bestcost"], nr['englishname'],
            #                                                 dftraindata["predicted.englishname"])
            # dftraindata["bestmatchcount"] = np.where(cost[0] == dftraindata["bestcost"],
            #                                          dftraindata["bestmatchcount"] + 1, dftraindata["bestmatchcount"])
            # dftraindata["bestcost"] = np.where(cost[0] < dftraindata["bestcost"], cost[0], dftraindata["bestcost"])

            # for i, r in dftraindata.iterrows():
            #    pass
            #     cost= self.GetWeightedDistance(r["persionname"], nr['englishname'])
            #     if (cost  < r["bestcost"]):
            #         r["bestcost"] = cost;
            #         r["predicted.englishname"]=nr["englishname"]
            #         r["bestmatchcount"]=1;
            #     if (cost == r["bestcost"]) :
            #         r["bestmatchcount"] += r["bestmatchcount"]
        print(dftraindata)
        print(i)


    def GetWeightedDistance(self, source, dest):



        #print lev(source, dest, substitute_costs=substitute_costs)  # prints '1.25'

        # it's not symmetrical! in this case, it is substituting 'B' for 'H'
        #print lev(source,dest, substitute_costs=substitute_costs)  # prints '1'

        # to make it symmetrical, you need to set both costs in the 2D array
        #substitute_costs[ord('B'), ord('H')] = 1.25  # make substituting 'B' for 'H' cost 1.25 as well
        # , substitute_costs=substitute_costs

        return lev(source,dest, insert_costs=self.insert_costs, delete_costs=self.delete_costs,substitute_costs=self.substitute_costs )  # now it prints '1.25'



# /Users/aparnaelangovan/Documents/Programming/python/Weighted-Levenshtein/python/pythonleven/bin/python /Users/aparnaelangovan/Documents/Programming/python/Weighted-Levenshtein/persian-names.py
# 1490272655.3
# merge time for cost
# 2.15284609795
# time for cost with vector
# 584.714901924
# time for group
# 2.81526899338
# 166
# 999.0
# 0.166166166166