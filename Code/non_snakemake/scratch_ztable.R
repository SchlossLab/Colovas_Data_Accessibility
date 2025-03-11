#20250311 - trying to figure out where my ztable got all messed up 

# library statements
library(tidyverse)

#the tokens to collapse and z tables are the same for both so we should be good there
tokens_to_collapse <-read_csv("Data/ml_prep/groundtruth.data_availability.tokens_to_collapse.csv")
ztable_filtered <- read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable_filtered.csv")
ztable_og <-read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable.csv.gz")

da_model <- 
    readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS")
nsd_model <- 
    readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.finalModel.RDS")

