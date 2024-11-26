#!/usr/bin/env Rscript
#take scraped html and end with a tibble of predictions
#
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)
library(httr2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(data.table) #unclear if i need this one yet

library(tokenizers)

#read in list of html files from filepath
# pat said do all of them at once...which means they
# all need to be scraped before this 
# test with a group of 5 or something


# #snakemake 
# input <- commandArgs(trailingOnly = TRUE)
# input_file <- read.table(input[1])  %>% 
#     select(paper, html_filename) %>%
#     mutate(clean_html = NA)
# input_path <- input[2]
# output_file <- input[3]


#functions

#function for reading html, remove figs/tables, 
#and concatenate abstract and body (using rvest, xml2)
webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  body_notables <- body %>%
    html_elements(css = ".table > *") %>%
    html_children() %>%
    xml_remove()
  
  body_nofigures <- body %>%
    html_elements(css = ".figure-wrap > *") %>%
    html_children() %>%
    xml_remove()
  
  paper_html <- paste0(abstract, body, collapse = " ") 
  
  return(paper_html)
  
}

# function to prep HTML using package tm
prep_html_tm <- function(html) {
  html <- as.character(html)
  html <- read_html(html) %>% html_text()
  html <- str_to_lower(html)
  html <- stripWhitespace(html)
  html <- removePunctuation(html)
  html <- str_remove_all(html, "[[:digit:]]")
  html <- str_remove_all(html, "[[^a-z ]]")
  html <- lemmatize_strings(html)
}



# tokenize paper with snowball stopwords

tokenize <- function(clean_html) {

  tokens <- tokenize_ngrams(clean_html, 
                  n_min = 1, n = 3,
                  stopwords = stopwords::stopwords("en", source = "snowball")) 
  token_tibble <-tibble(tokens = unlist(tokens))
  token_tibble <- add_count(token_tibble, tokens, name = "frequency")
  token_tibble <- unique(token_tibble)

}

#20241126 - from ml_prep_predict
#you can't remove near zero variants from things that only
# appear in one paper, but also it shouldn't really matter
#need to add the journal name (cotainer.title)

#ok first join to the ztable to find missing tokens
#how different are the ztables?
ztable <- read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable_filtered.csv")
missing_tokens <- anti_join(ztable, tokens_1)

#add missing back into the first table (need to update)
full_ml_with_missing <- full_ml
for (i in 1:nrow(missing_full_ml_tokens)) {

    missing_var <- missing_full_ml_tokens$tokens[[i]]
    
    full_ml_with_missing <-
        full_ml_with_missing %>%
            mutate("{missing_var}" := 0)

}






#generate files and use on 1 file
# 20241126 - need to figure out how to keep doi with it...
#20241126 - also need to do linkrot in same file bc html is here

# 20241125 - if filesize > 0 

all_html <- list.files("Data/html", full.names = TRUE)

some_html <-
  grep("jmbe", all_html, value = TRUE) %>% 
  head(20)

file.size(some_html)


one_html_file <- some_html[1]

webscrape_1 <- webscrape(one_html_file)

clean_html_1 <- prep_html_tm(webscrape_1)
str(clean_html_1)

tokens_1 <- tokenize(clean_html_1)

