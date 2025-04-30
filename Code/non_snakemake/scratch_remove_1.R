#library 
library(tidyverse)

da<-readRDS("Data/preprocessed/groundtruth.data_availability.preprocessed.RDS")

grep("_1", da$grp_feats, value = TRUE)
