#!/usr/bin/env Rscript
# predict.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)

# snakemake input 
input <- commandArgs(trailingOnly = TRUE)
rds <- input[1]
data_processed <- readRDS(rds)
ml_var_snake <- input[2]
output_dir <- input[4]

#manual input 
rds <- "Data/1935-7885_metadata.RDS"
data_processed <- readRDS(rds)

write_csv(data_processed, file = "Data/1935-7885.csv")
