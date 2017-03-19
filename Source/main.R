source("./Utilities.R")
source("./editdistance_scorer.R")
## main
output_dir ="../output"
output_dir <- setup_outdir(output_dir)

sink()
#setup_log(output_dir)
flog.threshold(INFO)
set_options()

input_dir = "../input_data"


#load data
traindata <- read.csv(file.path(input_dir, "train.txt"),sep="\t",  header=F, na.strings=c(".",""), as.is=c("PersionName","EnglishName"), col.names = c("PersionName","EnglishName"))[1:50,]
namesdata <- read.csv(file.path(input_dir, "names.txt"), col.names = "EnglishName")
#global edit distance same scores for r=i=d
scorer <- editdistance_scorer(traindata,namesdata,output_dir)
run_pipeline(scorer)
#global edit distance with higher r>(i=d)
scorer <- editdistance_scorer(traindata,namesdata,output_dir,i=1,d=1, r=2)
run_pipeline(scorer)
#global edit distance with higher (i=d)>r
scorer <- editdistance_scorer(traindata,namesdata,output_dir, i=2,d=2, r=1)
run_pipeline(scorer)
#global edit distance with i<r<d as in the train data
#     25% persian and latin names have the same length
#     72% of latin names are longer, only 3%~ are shorten than the persian names
scorer <- editdistance_scorer(traindata,namesdata,output_dir, i=1, d=3,r=2)
run_pipeline(scorer)
