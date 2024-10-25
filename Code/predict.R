#!/usr/bin/env Rscript
# predict.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(mikropml)
library(randomForest)

# snakemake implementation
# {input.rscript} {input.da} {input.nsd} {input.metadata} {output}
input <- commandArgs(trailingOnly = TRUE)
da_tokens <- readRDS(input[1])
nsd_tokens <- readRDS(input[2])
metadata  <-  read_csv(input[3])
outfile <- input[4]

# load in models 
da_model <- 
    readRDS("Data/ml_results/groundtruth/rf/data_availability/final/final.rf.data_availability.102899.finalModel.RDS")

nsd_model <- 
    readRDS("Data/ml_results/groundtruth/rf/new_seq_data/final/final.rf.new_seq_data.102899.finalModel.RDS")


# local files for testing
da_tokens <- readRDS("Data/preprocessed/2576-098X.data_availability.preprocessed_predict.RDS")
nsd_tokens <- readRDS("Data/preprocessed/2576-098X.new_seq_data.preprocessed_predict.RDS")
metadata <- read_csv("Data/doi_linkrot/alive/2576-098X.csv")

#make sure all colnames from model are in the zscored datasets
#should return integer(0)
all(da_model$xNames %in% colnames(da_tokens))
all(da_model$xNames %in% colnames(nsd_tokens))

#make the predictions
da_prediction <-
     predict(da_model, newdata = da_tokens, type = "response")

nsd_prediction <-
     predict(da_model, newdata = nsd_tokens, type = "response")

# add column for the prediction to a new df with just paper and prediction
doi_with_nsd <- 
nsd_tokens %>% 
    mutate(nsd_prediction = nsd_prediction) %>%
    select(paper_doi, nsd_prediction)
     
doi_with_da <- 
da_tokens %>% 
    mutate(da_prediction = da_prediction) %>%
    select(paper_doi, da_prediction)


#join with metadata from snakerule doi_linkrot

metadata_with_predictions <- 
left_join(metadata, doi_with_nsd, by = join_by("paper" =="paper_doi")) %>% 
        left_join(.,  doi_with_da, by = join_by("paper" == "paper_doi"))

#select paper, nsd_prediction, da_prediction

metadata_with_predictions  <- 
metadata_with_predictions %>% 
    select(paper, nsd_prediction, da_prediction) 

#fill in filename with snakemake 
saveRDS(metadata_with_predictions, file = outfile)

