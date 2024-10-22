#!/usr/bin/env Rscript
# predict.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(mikropml)
install.packages("randomForest", repos = "https://repo.miserver.it.umich.edu/cran/")
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

tokens <- readRDS("Data/1935-7885_alive.data_availability.preprocessed_predict.RDS")
str(tokens)

tokens$paper_doi
View(head(tokens, 5))

#do i need to remove the truth column from the model? 


# 20241022 - variables in the training data missing in newdata
#they should not be missing in newdata
# i have no idea how to fix this 
predictions <- predict(da_model, newdata = tokens, type = "response")

any(da_model %in% tokens) 

#20241022  - which ones are still missing 
#what do i do about these ones.... they should have been added? 

which(!(da_model$xNames %in% colnames(tokens)))
da_model$xNames[211] #"`interest importance`_1"
da_model$xNames[1494] #"paper.y"
da_model$xNames[1686] #"`material method bacterial`_1"

head(da_model)

#from kelly
# and then use that to predict the classification for the held out data.
# predictions <- predict(final_model, newdata = test_data, type = 'prob')


