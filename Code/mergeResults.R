#!/usr/bin/env Rscript
# merge results of training ml models using mikropml and many seeds
#
#
#library statements
library(tidyverse)

# load files 

# snakemake 
input <- commandArgs(trailingOnly = TRUE)
filepath <- input[1]
method <- as.character(input[2])
ml_var <- input[3]

#local

# "Data/ml_results/groundtruth/runs/{method}/{method}.{seeds}.{ml_variables}.performance.csv"
# method <- "rf"
# filepath <- str_glue("Data/ml_results/groundtruth/{method}")

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

    
results$trained_on <- map(results$file_path, str_split_i, pattern = "\\.", i = 3)

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
   


