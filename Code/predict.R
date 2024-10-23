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

da_tokens <- readRDS("Data/1935-7885_alive.data_availability.preprocessed_predict.RDS")


# 20241022 - variables in the training data missing in newdata-
# issues with naming
# predictions <- predict(da_model, newdata = tokens, type = "response")

any(da_model %in% da_tokens) 


# so are these duplicates? 
which(!(da_model$xNames %in% colnames(da_tokens)))
da_model$xNames[1494] #"paper.y" 
#this one can just be a change of colunmname

da_model$xNames[211] #"`interest importance`_1"
da_model$xNames[1686] #"`material method bacterial`_1"

#search to see if these are duplicates
grep("interest", da_model$xNames, value = TRUE)
grep("material", da_model$xNames, value = TRUE)
grep("_1", da_model$xNames, value = TRUE)

head(da_model)

#honestly i think the column titles just got all funky and we can just change them 

renamed_da_tokens <-
da_tokens %>% 
    rename("paper.y" = "paper",
        "`interest importance`_1" = "interest importance",
        "`material method bacterial`_1" = "material method bacterial")

#okay this works but what do i do with it
da_predictions <- predict(da_model, newdata = renamed_da_tokens, type = "response")



#from kelly
# and then use that to predict the classification for the held out data.
# predictions <- predict(final_model, newdata = test_data, type = 'prob')



#also need the other model, are there other things that we don't have in this dataset?

nsd_model_rds <- "Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.finalModel.RDS"
nsd_model <- readRDS(nsd_model_rds)

nsd_tokens <- readRDS("Data/1935-7885_alive.new_seq_data.preprocessed_predict.RDS")
str(nsd_tokens)


#check all things exist
any(da_model %in% da_tokens) 

# so are these duplicates? 
which(!(da_model$xNames %in% colnames(nsd_tokens)))

renamed_nsd_tokens <-
nsd_tokens %>% 
    rename("paper.y" = "paper",
        "`interest importance`_1" = "interest importance",
        "`material method bacterial`_1" = "material method bacterial")

nsd_predictions <- predict(da_model, newdata = renamed_nsd_tokens, type = "response")

