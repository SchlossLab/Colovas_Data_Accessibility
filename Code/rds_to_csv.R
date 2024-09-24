#!/usr/bin/env Rscript
# predict.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)

# snakemake input 
#  {input.rscript} {input.rds} {output}
input <- commandArgs(trailingOnly = TRUE)
rds <- input[1]
data_processed <- readRDS(rds)
output <- input[2]

#local practice 
# rds <- "Data/1935-7885_metadata.RDS"
# data_processed <- readRDS(rds)


data_processed <-
    data_processed %>%
        mutate(paper = paste0("https://journals.asm.org/doi/", doi)) %>%
        relocate(paper, .before = container.title)


write_csv(data_processed, file = output)
