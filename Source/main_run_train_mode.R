source("./Utilities.R")
source("./editdistance_scorer.R")
## main
output_dir ="../output"
output_dir <- setup_outdir(output_dir)

sink()
setup_log(output_dir)
flog.threshold(INFO)
set_options()

input_dir = "../input_data"



#load data
traindata <- read.csv(file.path(input_dir, "train.txt"),sep="\t",  header=F, na.strings=c(".",""), as.is=c("PersionName","EnglishName"), col.names = c("PersionName","EnglishName"))
namesdata <- read.csv(file.path(input_dir, "names.txt"), col.names = "EnglishName")

#global edit distance r=1
scorer <- editdistance_scorer(traindata,namesdata,output_dir, r=1)
run_pipeline(scorer)
#global edit distance r=2
scorer <- editdistance_scorer(traindata,namesdata,output_dir, r=2)
run_pipeline(scorer)
#global edit distance r=3
scorer <- editdistance_scorer(traindata,namesdata,output_dir, r=3)
run_pipeline(scorer)