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



da_model <- 
    readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS")
nsd_model <- 
    readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.finalModel.RDS")


da_model_diff <- 
    readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.model.RDS")
nsd_model_diff <- 
    readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.model.RDS")

str(da_model_diff$trainingData["`material method bactericidal`_1"])
grep("_", da_model_diff$trainingData)

da_model_diff$trainingData[c("`interest importance`_1", "`interest importance`_0") ]
da_model_diff$trainingData[c("`material method bacterial`_1", "`material method bacterial`_0") ]
head(da_model_diff$trainingData[c("grp1", "grp2", "grp3", "dodecyl sulfate", "sodium dodecyl sulfate")])

str(da_model)
str(da_model_diff)
