#library
library(tidyverse)
library(caret)

da <- readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS")
nsd<- readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.finalModel.RDS")

da_model_final <- readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.model.RDS")
nsd_model_final <- readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.model.RDS")

da_model_best <- readRDS("Data/ml_results/groundtruth/rf/data_availability/best/best.rf.data_availability.102899.model.RDS")
nsd_model_best <- readRDS("Data/ml_results/groundtruth/rf/new_seq_data/best/best.rf.new_seq_data.102899.model.RDS")

str(da_model)
da$confusion
nsd$confusion
da$tuneValue
str(da_model_best)
str(da_model_best$finalModel)
view(da_model_best$results)
da_model_best$resample
d

str(da_model$finalModel)
da_model$finalModel$confusion


da_model_best$finalModel$confusion
da_model_best$results
da_model_final$results

str(da_model_best$trainingData)
str(da_model_best)
