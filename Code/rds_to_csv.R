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
rds <- "Data/1935-7885_metadata.RDS"
data_processed <- readRDS(rds)

data_processed <-
    data_processed %>% 
        filter(!grepl("x14", doi)) %>%
        mutate(paper = paste0("https://journals.asm.org/doi/", doi)) %>%
        relocate(paper, .before = container.title) 

# map(data_processed$url, grepl, pattern = "x14")

# data_processed_alive <-
#     data_processed %>%
#         slice_tail(., n = -(37))


data_processed$url %>%
    grep(pattern = "x14")


data_processed_alive$url %>%
    grep(pattern = "x14")

write_csv(data_processed, file = "Data/1935-7885_alive.csv")
