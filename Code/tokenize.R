# tokenize.R
# tokenization function that takes clean html as input 
#
#
#
# load packages
library(tidyverse)
#library(rvest)
library(tidytext)
library(xml2)
#library(jsonlite)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(tokenizers) #for text tokenization

# # for snakemake implementation
# clean_text <-  read.csv(snakemake.input[0])

#for other implementation
clean_text <- read.csv("Data/gt_subset_30_data_clean_html.csv.gz")


#tokenize cleaned text
clean_text$paper_tokens <- 
  tokenize_ngrams(clean_text$clean_html, 
                  n_min = 1, n = 3,
                  stopwords = stopwords::stopwords("en"))

#unnest cleaned text? do i need to do this? 
#20240522 - this part of the script doesn't work, will need to come back
clean_text$unnested_tokens <- map_chr(clean_text, unnest, cols = paper_tokens)
