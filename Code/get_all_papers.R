#!/usr/bin/env Rscript
# get_all_papers.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)

# snakemake input 
#  {input.rscript} {params.dir} {output}
input <- commandArgs(trailingOnly = TRUE)
papers_dir <- input[1]
output <- input[2]


# local practice 
# papers_dir <- "Data/papers"
output<-"Data/papers/all_papers.csv.gz"

csv_files <- list.files(papers_dir, "*.csv")


all_papers <- tribble(~paper, ~unique_id)

for (i in 1:12) {
    csv_file <- read_csv(paste0(papers_dir, "/", csv_files[i])) %>%
        select(., c(paper, unique_id))
    all_papers <- full_join(all_papers, csv_file)
}

all_papers <-
    all_papers %>%
        rename(url = paper, doi = unique_id)

write_csv(all_papers, file = output)
