#!/usr/bin/env Rscript
# all_papers.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)

# snakemake input 
#  {input.rscript} {params.dir} {output}
input <- commandArgs(trailingOnly = TRUE)
papers_dir <- input[1]
output <- input[2]


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
            html_filename = paste0(html_dir, unique_id, ".html")) %>%
        unique()



write_csv(data_processed, file = output)
