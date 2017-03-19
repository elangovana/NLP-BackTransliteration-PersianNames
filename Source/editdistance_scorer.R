source("./generic_s3_methods.R")

# editdistance  scorer 
editdistance_scorer <- function(traindata, namesdata, output_dir,i=1,d=1, r=1){
  #######todo validate

  
  ####output
  out <- list(traindata = traindata, 
              namesdata = namesdata,
              result = NULL,
              significancelevel=-1,
              totalcorrect=-1,
              percentagecorrect=-1,
              resultEditDistance=NULL,
              m=0,
              i=i,
              d=d,
              r=r,
              output_dir=setup_outdir(output_dir, "editdistance_scorer")
             )
  class(out) <- "editdistance_scorer"
  
  
  ### Remove irrelavant  data, data with discontinued is > discont_in_months 
  
  
  
  invisible(out)
}


#This is the processing pipeline
run_pipeline.editdistance_scorer  <- function(object){
  flog.info("Begin run_pipeline.editdistance_scorer")
  
 
  #calculate
  object <- predict(object)
  #calcute score
  object <- score_model(object)
  #write all to file
  write_to_file(object)
  #return results
  summary(object)
  
  flog.info("End run_pipeline.editdistance_scorer")
  invisible(object)
  
}



#This predicts the spelling based on leventine distance
predict.editdistance_scorer <- function(object){
  flog.info("predict editdistance_scorer")
  
  #Compute distance
  lventian_edit_dist <- adist(object$traindata$PersionName,object$namesdata$EnglishName,ignore.case = TRUE, costs = list(insertions=object$i,deletions=object$d,substitutions=object$r))
  rownames(lventian_edit_dist)<- object$traindata$PersionName
  colnames(lventian_edit_dist)<- object$namesdata$EnglishName
 
  #Obtain max score or min cost
  mincost<-apply(lventian_edit_dist, 1, function(x) min(x))
  #Get any one matching english name with min cost
  bestmatch<-apply(lventian_edit_dist, 1, function(x) colnames(lventian_edit_dist)[which.min(x)])
  #Get the count of english names with  the lowest cost
  bestmatchcount<-apply(lventian_edit_dist, 1, function(x) length(colnames(lventian_edit_dist)[(x==min(x))]))
  #Get the english names with  the lowest cost
  bestmatchedstrings<-apply(lventian_edit_dist, 1, function(x) paste(colnames(lventian_edit_dist)[(x==min(x))],collapse="|"))
 
  #results
  object$result=data.frame(PersionName=rownames(lventian_edit_dist),score=mincost, Predicted.EnglishName=bestmatch, EnglishName=object$traindata$EnglishName, BestMatchCount=bestmatchcount, BestMatchedStrings=bestmatchedstrings) 
  object$resultEditDistance = lventian_edit_dist
  return(object)
}

score_model.editdistance_scorer <- function(object){
  flog.info("Running score_model.editdistance_scorer")
  # obtain total correct based on lowest score, provided there is only one low score. Ties are scored as incorrect
  totalcorrect=length(which(as.character(object$result$Predicted.EnglishName) == object$result$EnglishName & object$result$BestMatchCount ==1))
  totalrecords=length(rownames(object$result))
  totalnamechoices = length(colnames(object$result))
  percentagecorrect = (totalcorrect *100)/totalrecords
  #results
  object$totalcorrect=totalcorrect
  object$percentagecorrect=percentagecorrect
  #significance level is computed using :
  #         binomial distribution : C(n,r)*p^r*q^(n-r), 
  #         where p = 1/(total number of english names in dictionary)
  #               n= total number of records
  #               r= number of correct answers
  object$significancelevel = choose(totalrecords, totalcorrect)*(1/totalnamechoices)^totalcorrect*((totalnamechoices-1)/totalnamechoices)^(totalrecords-totalcorrect)
  
  
  return(object)
}

#This writes all data into file
write_to_file.editdistance_scorer <- function(object){
  flog.info("Running write_to_file.editdistance_scorer")
  write.csv(object$result,file.path(object$output_dir, "results.csv"),row.names=FALSE)
  write.csv(object$resultEditDistance, file.path(object$output_dir, "leventaindistance.csv"))
}


print.editdistance_scorer <- function(object){
  #todo
  print("input data")
  print(str(object$traindata))
  print("names data")
  print(str(summary(object$names)))
  print("result")
  print(str(object$result))
  print("total correct")
  print(object$totalcorrect)
  print("percentage correct")
  print(object$percentagecorrect)
}

summary.editdistance_scorer <- function(object){
  #todo
  print("Summary summary.editdistance_scorer")
  print("-----------------------------------")
  print("Dimensions of traindata ")
  print(dim(object$traindata))
  print("Dimensions of  namesdata")
  print(dim(object$namesdata))
  print(paste("Scoring used : m =", object$m, "r=", object$r, "i=",object$i, "d=",object$d))
  print(paste("Total correct:", object$totalcorrect ))
  print(paste("Percent correct:", object$percentagecorrect ))
  print(paste("Significance level (probability of randomly correct):",object$significancelevel))
  print("---end summary.editdistance_scorer--")

}
