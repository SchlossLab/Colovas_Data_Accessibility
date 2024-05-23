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

# save files 
write.csv(clean_text, 
          file = output_file, 
          row.names = FALSE)


