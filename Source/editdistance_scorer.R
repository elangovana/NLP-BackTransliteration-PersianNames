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
 
  #Obtain max score
  maxScore<-apply(lventian_edit_dist, 1, function(x) min(x))
  bestmatch<-apply(lventian_edit_dist, 1, function(x) colnames(lventian_edit_dist)[which.min(x)])
  #results
  object$result=data.frame(PersionName=rownames(lventian_edit_dist),score=maxScore, Predicted.EnglishName=bestmatch, EnglishName=object$traindata$EnglishName) 
 
  return(object)
}

score_model.editdistance_scorer <- function(object){
  flog.info("Running score_model.editdistance_scorer")
  totalcorrect=length(which(as.character(object$result$Predicted.EnglishName) == object$result$EnglishName))
  totalrecords=length(rownames(object$result))
  totalnamechoices = length(colnames(object$result))
  percentagecorrect = (totalcorrect *100)/totalrecords
  #results
  object$totalcorrect=totalcorrect
  object$percentagecorrect=percentagecorrect
  object$significancelevel = choose(totalrecords, totalcorrect)*(1/totalnamechoices)^totalcorrect*((totalnamechoices-1)/totalnamechoices)^(totalrecords-totalcorrect)
  
  
  return(object)
}

#This writes all data into file
write_to_file.editdistance_scorer <- function(object){
  write.csv(object$result,file.path(object$output_dir, "results.csv"),row.names=FALSE)
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
