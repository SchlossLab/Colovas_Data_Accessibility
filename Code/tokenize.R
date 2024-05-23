#!/usr/bin/env Rscript
# tokenize.R
# tokenization function that takes clean html as input 
#
#
# load packages
# library(rvest)
# library(jsonlite)

library(tidyverse)
library(tidytext)
library(xml2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(tokenizers) #for text tokenization

# for snakemake implementation
input <- commandArgs(trailingOnly = TRUE)
clean_csv <- input[1]
output_file <- input[2]
clean_text <- read.csv(clean_csv)

# #other implementation
# clean_text <- read.csv("Data/gt_subset_30_data_clean_html.csv.gz")


#tokenize cleaned text
clean_text$paper_tokens <- 
  tokenize_ngrams(clean_text$clean_html, 
                  n_min = 1, n = 3,
                  stopwords = stopwords::stopwords("en"))
clean_text <- select(clean_text, !"clean_html")

#unnesting makes long 2 col df with doi and each token in col 2
clean_text <- unnest(clean_text, cols = paper_tokens)

#want to count occurrences of each token and remove duplicate tokens
clean_text <- group_by(clean_text, paper_doi)
clean_text <- add_count(clean_text, paper_tokens, name = "frequency")
clean_text <- unique(clean_text)

# save files 
write.csv(clean_text, 
          file = output_file, 
          row.names = FALSE)


