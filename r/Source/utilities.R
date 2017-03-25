library("futile.logger")
source("./generic_s3_methods.R")




setup_warning_options <- function(){
  options(warning.length = 5000)
  options(warn =1)
}

#set up logging
setup_log <- function(outdir){
  con <- file(file.path(outdir,"runall.log"))
  sink(con, append=TRUE)
  sink(con, append=TRUE, type="message")
  
  
  appender.file(con)
  #layout <- layout.format('[~l] [~t] [~n.~f] ~m')
  #flog.layout(layout)
  
  return(con)
}

setup_outdir <- function(base_dir, sub_directory_prefix=""){
  if (!file.exists(base_dir)){  
    dir.create(file.path(".", base_dir)) 
  }
  cur_time=format(Sys.time(), "%Y%m%d_%H%M%S")
  outdir = file.path(base_dir, paste(sub_directory_prefix, cur_time, sep=""))
  dir.create(outdir, cur_time)  
  return(outdir)
}

