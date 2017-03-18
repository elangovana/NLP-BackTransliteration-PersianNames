source("./Utilities.R")
## main
output_dir ="./outdat_trainmode"
output_dir <- setup_outdir(output_dir)

sink()
#setup_log(out_dir)
flog.threshold(INFO)
set_options()

input_dir = "./input_data"



#load data
traindata <- read.csv(file.path(input_dir, "train.txt"),sep="\t",  header=F, na.strings=c(".",""), as.is=c("PersionName","EnglishName"), col.names = c("PersionName","EnglishName"))[1:10,]
namesdata <- read.csv(file.path(input_dir, "names.txt"), col.names = "EnglishName")
(print(summary(traindata)))
(print(summary(namesdata)))
#Compute distance
lventian_edit_dist <- adist(traindata$PersionName,namesdata$EnglishName,ignore.case = TRUE)
rownames(lventian_edit_dist)<- traindata$PersionName
colnames(lventian_edit_dist)<- namesdata$EnglishName
print(head(colnames(lventian_edit_dist)))
#Obtain max score
maxScore<-apply(lventian_edit_dist, 1, function(x) min(x))
bestmatch<-apply(lventian_edit_dist, 1, function(x) colnames(lventian_edit_dist)[which.min(x)])
#results
result=data.frame(PersionName=rownames(lventian_edit_dist),score=maxScore, Predicted.EnglishName=bestmatch, EnglishName=traindata$EnglishName) 
#print
(print(result))
#writeoutputtofile
write.csv(result,file.path(output_dir, "results.csv"),row.names=FALSE)
#summary
totalcorrect=length(which(as.character(result$Predicted.EnglishName) == result$EnglishName))
print(paste("TotalCorrect =", totalcorrect, "percentage correct=",(totalcorrect*100)/length(rownames(result)),"%"))
# 
# 
# flds <- createFolds(y, k = 10, list = TRUE, returnTrain = FALSE)
# 
# g_seeds_classifier=NULL
# g_seeds_classifier=c("./random_seeds/cleanup.discontinued_classifier_1.seed", "./random_seeds/model.discontinued_classifier_2.seed")
# 
# g_seeds_risk_scorer=NULL
# g_seeds_risk_scorer=c( "./random_seeds/model.discontinued_risk_scorer_1.seed", NA, "./random_seeds/cleanup.discontinued_risk_scorer_3.seed")
# 
# 
# #rows_in_train = c(1100:1300,1401:1600)
# rows_in_train = c(1:400, 901:1600)
# #rows_in_train = c(1:200, 301:700, 801:1000)
# rows_in_test = c(401:900)
# #rows_in_test = c(1301:1400)
# #rows_in_train = c(1401:1600)
# #rows_in_test = c(201:300)
# 
# source("./challenge_data.R")
# train_challenge_data <- challenge_data(input_data_train_dir, "_training.csv", rows_in_train)
# test_challenge_data <- challenge_data(input_data_train_dir, "_training.csv", rows_in_test)
# 
# source("./discontinued_classifier_caret.R")
# for(i in c(1:1)){
#   classifier <- discontinued_classifier(train_challenge_data, test_challenge_data, 90.5, out_dir, seed_files=g_seeds_classifier)
#   run_pipeline(classifier)
# }
# 
# # source("./discontinued_risk_scorer.R")
# # risk_scorer <- discontinued_risk_scorer(train_challenge_data, test_challenge_data, 90.5, out_dir, seed_files=g_seeds_risk_scorer)
# # run_pipeline(risk_scorer)
