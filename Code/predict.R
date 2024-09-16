#!/usr/bin/env Rscript
# predict.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)
library(mikropml)

# snakemake implementation
# read in 2x models, the preprocessed .RDS files
# input <- commandArgs(trailingOnly = TRUE)
# rds <- input[1]
# data_processed <- readRDS(rds)
# ml_var_snake <- input[2]
# output_dir <- input[4]
