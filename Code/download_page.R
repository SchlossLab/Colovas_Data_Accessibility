#!/usr/bin/env Rscript
#
# download_page.R
# take paper DOI and download entire page into folder
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)

# #command line inputs
# input <- commandArgs(trailingOnly = TRUE)
# input_file <- input[1]
# output_file <- input[2]

# local input
input_file <- read_csv("Data/doi_linkrot/alive/1935-7885.csv")
colnames(input_file)

# iterate through each doi 

# webscrape and save back to each doi

# how to save all of them as snakemake files and know that it has all the files

one_paper <- input_file$paper[1]

html <- read_html(one_paper)

view(html)

save_html

#use save_html in htmltools
library(htmltools)

#have to figure out how to save these, might need just doi or put doi in quotes
save_html(html, file = paste0("Data/", one_paper))
