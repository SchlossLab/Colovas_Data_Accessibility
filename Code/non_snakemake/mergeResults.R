#!/usr/bin/env Rscript
# merge results of training ml models using mikropml and many seeds
#
#
#library statements
library(tidyverse)
library(mikropml)
# load files 

# snakemake 
input <- commandArgs(trailingOnly = TRUE)
filepath <- input[1]
method <- as.character(input[2])
ml_var <- input[3]

##local checks for updated file locations
# rds <- "Data/groundtruth.data_availability.preprocessed.RDS"
# data_processed <- readRDS(rds)
# seed <- 1
# ml_var_snake <- "data_availability"
# output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}")

## local checks for old file locations
# filepath <- "Data/ml_results/groundtruth/rf"
# method <- "rf"
# ml_var <- "data_availability"
# output_dir <- paste0("Data/ml_results/groundtruth/rf/{ml_var_snake}")

#remove "{method}", and then group by method, then you can summarize in one df
# need to group trained models by the variable used in the filename!!! 
#"Data/ml_results/groundtruth/new_seq_data"

files_list <- list.files(filepath, 
                        pattern = "*.csv", 
                        full.names = TRUE)

# avail_files_list <- list.files(filepath, 
#                         pattern = str_glue("data_availability.*.csv"), 
#                         full.names = TRUE)

results <- read_csv(files_list, id = "file_path")


results <- results %>%
    mutate(trained_on = str_split_i(file_path, pattern = "\\.", i = 3))

# seq_results <- read_csv(seq_files_list)
# avail_results <- read_csv(avail_files_list)

#colnames(results)

# seq_results <- seq_results %>% 
#     select(seed, method, everything(results)) %>% 
#     select(!...1) 

# avail_results <- avail_results %>% 
#     select(seed, method, everything(results)) %>% 
#     select(!...1) 

# need to summarize by group 
results_method <- results %>%
    summarize(.by = c("method", "trained_on"), 
                mean_cv_AUC = mean(cv_metric_AUC), 
                mean_accuracy = mean(Accuracy), 
                mean_sens = mean(Sensitivity), 
                mean_spec = mean(Specificity), 
                mean_precision = mean(Precision)) 
   
str(results_method)
write.csv(results_method, file = outfile)

