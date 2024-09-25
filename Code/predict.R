#!/usr/bin/env Rscript
# predict.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(mikropml)
install.packages("randomForest")
library(randomForest)

# snakemake implementation
# read in 2x models, the preprocessed .RDS files
# input <- commandArgs(trailingOnly = TRUE)
# rds <- input[1]
# data_processed <- readRDS(rds)
# ml_var_snake <- input[2]
# output_dir <- input[4]

# for local testing 
da_model_rds <- "Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS"
da_model <- readRDS(da_model_rds)

tokens <- readRDS("Data/1935-7885_alive.preprocessed.RDS")
str(tokens)

View(head(tokens, 5))

#the dataset isn't in the right format to be fed into the model to be predicted
#need to use ML prep as a guide for how to deploy the models

# 20240925 - data is in the right format after preprocessing
# BUT "number of variables in newdata does not match that in the training data"
predictions <- predict(da_model, newdata = tokens, type = "response" )



#from kelly
# and then use that to predict the classification for the held out data.
# predictions <- predict(final_model, newdata = test_data, type = 'prob')


