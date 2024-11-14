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
html_dir <- input[3]

#local practice 
# rds <- "Data/metadata/1935-7885_metadata.RDS"
# data_processed <- readRDS(rds)
# html_dir <- "Data/html/1935-7885/"


data_processed <-
    data_processed %>%
        mutate(paper = paste0("https://journals.asm.org/doi/", doi)) %>%
        relocate(paper, .before = container.title) %>%
        mutate(unique_id = str_split_i(doi, "/", -1), 
            html_link_status = as.numeric(0), 
            html_filename = paste0(html_dir, unique_id, ".html"))



write_csv(data_processed, file = output)
