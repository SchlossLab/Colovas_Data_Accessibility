#!/usr/bin/env Rscript
# dataset_split.R
#splitting datasets >15K records into smaller chunks
#
#
# library statements
library(tidyverse)
library(tidytext)

# snakemake input 
#  {input.rscript} {input.rds} {output}
# "Data/papers/{datasets}"
#"Data/papers/{datasets}-2.csv"

input <- commandArgs(trailingOnly = TRUE)
csv <- input[1]
data_processed <- read_csv(csv)
filepath <- input[2]

# #local practice 
# csv <- "Data/papers/0095-1137.csv"
# data_processed <- read_csv(csv)

data_1 <- slice_head(data_processed, n = 10000)
data_2 <- anti_join(data_processed, data_1)

write_csv(data_1, file = paste0(filepath, "-1.csv"))
write_csv(data_2, file = paste0(filepath, "-2.csv"))