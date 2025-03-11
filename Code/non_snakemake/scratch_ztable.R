#20250311 - trying to figure out where my ztable got all messed up 

# library statements
library(tidyverse)

#the tokens to collapse and z tables are the same for both so we should be good there
tokens_to_collapse <-read_csv("Data/ml_prep/groundtruth.data_availability.tokens_to_collapse.csv")
ztable_filtered <- read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable_filtered.csv")
ztable_og <-read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable.csv.gz")

da_model <- 
    readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS")


#assign vars to each thing so that it's easier to get what i want out
model_names <- da_model$xNames
og_z_names <-ztable_og$tokens
filtered_z_names<-ztable_filtered$tokens

#okay is it missing from the og z table 
missing<-which(!(og_z_names %in% model_names))
model_names[missing]

missing_2<-which(!(filtered_z_names %in% model_names))
model_names[missing_2]
