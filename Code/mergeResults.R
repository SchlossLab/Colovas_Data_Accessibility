#!/usr/bin/env Rscript
# merge results of training ml models using mikropml and many seeds
#
#
#library statements
library(tidyverse)

# load files 

# snakemake 
input <- commandArgs(trailingOnly = TRUE)
# honestly i have no idea how to import all of these files.... maybe 
    # map statement/some kind of loop with just the file names with the seeds as a star?
    # let's go see how pat does it????
seed_files <- input[1]


# let's see what i can do without the snakemake 
# directory all the files are stored in: 
# "Data/ml_results/groundtruth/runs/{method}.{seeds}.{ml_variables}.performance.csv"

#will probably need to supply all the right wildcards from snakemake or READ from filenames
filepath <-"Data/ml_results/groundtruth"
#filepath <- paste0("Data/ml_results/groundtruth/runs/", method)

#remove "{method}", and then group by method, then you can summarize in one df
# need to group trained models by the variable used in the filename!!! 
#"Data/ml_results/groundtruth/new_seq_data"

seq_files_list <- list.files(filepath, 
                        pattern = str_glue("new_seq_data.*.csv"), 
                        full.names = TRUE)

avail_files_list <- list.files(filepath, 
                        pattern = str_glue("data_availability.*.csv"), 
                        full.names = TRUE)

seq_results <- read_csv(seq_files_list)
avail_results <- read_csv(avail_files_list)

#colnames(results)

seq_results <- seq_results %>% 
    select(seed, method, everything(results)) %>% 
    select(!...1) 

avail_results <- avail_results %>% 
    select(seed, method, everything(results)) %>% 
    select(!...1) 

# need to summarize by group 
results_method <- results %>%
    summarize(.by = method)
   


