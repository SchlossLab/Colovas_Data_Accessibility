#!/usr/bin/env Rscript
# rds_to_csv.R
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
# rds <- "Data/metadata/1935-7885_metadata.RDS"
# data_processed <- readRDS(rds)


data_processed <-
    data_processed %>%
        mutate(paper = paste0("https://journals.asm.org/doi/", doi), 
               unique_id = str_replace(doi, "/", "_")) %>%
        relocate(paper, .before = container.title)

write_csv(data_processed, file = output)
