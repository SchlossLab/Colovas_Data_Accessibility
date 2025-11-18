#!/usr/bin/env Rscript

#library
library(tidyverse)
library(caret)

#import files
input <- commandArgs(trailingOnly = TRUE)
nsd_model_best <- readRDS(input[1])
da_model_best <- readRDS(input[2])
output_file <- input[3]

#local file testing
# nsd_model_best <- readRDS("Data/ml_results/groundtruth/rf/new_seq_data/best/best.rf.new_seq_data.102899.model.RDS")
# da_model_best <- readRDS("Data/ml_results/groundtruth/rf/data_availability/best/best.rf.data_availability.102899.model.RDS")
# output_file <- "Data/final/best_model_stats.csv"

#get best tune 
nsd_best <- as.numeric(nsd_model_best$bestTune/100)
da_best <- as.numeric(da_model_best$bestTune/100)

#pivot files so that we can get the values we want out of this

da_best_stats<-da_model_best$results[da_best, ] %>% pivot_longer(1:29, names_to = "key", values_to = "value") %>% 
    rename(da_model = value)
nsd_best_stats<-nsd_model_best$results[nsd_best, ] %>% pivot_longer(1:29, names_to = "key", values_to = "value") %>% 
    rename(nsd_model = value)


all_model_stats<-full_join(da_best_stats, nsd_best_stats) %>% view()

write_csv(all_model_stats, file = output_file)
