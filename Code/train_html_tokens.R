#!/usr/bin/env Rscript
# cleanup_html.R
# clean up pre-saved html
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(data.table)
library(randomForest)
library(tokenizers)

#snakemake 
input <- commandArgs(trailingOnly = TRUE)
input_file <- read_csv(input[1])  %>% 
    select(doi_underscore, container.title) %>%
    mutate(clean_html = NA, 
          html_filename = paste0("Data/html/", doi_underscore, ".html"), 
          tokens = NA)
output_file <- input[2]


#local 
#20250220 - use new_groundtruth to get prepped for model training

# #import new groundtruth to get the html filename 
# input_file <- read_csv("Data/new_groundtruth_metadata.csv.gz")  %>% 
#     select(doi_underscore, container.title) %>%
#     mutate(clean_html = NA, 
#           html_filename = paste0("Data/html/", doi_underscore, ".html"), 
#           tokens = NA)



#function for reading html, remove figs/tables, 
#and concatenate abstract and body (using rvest, xml2)
webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  
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

#about 2 mins 
for (i in 1:nrow(input_file)) {
    if(!file.exists(input_file$html_filename[[i]])) {
        next
    }
   html <- webscrape(input_file$html_filename[[i]])
   html <- prep_html_tm(html)
   input_file$clean_html[[i]] <- html
    
}

# any(is.na(input_file$clean_html))

#about 3 mins
input_file$tokens <-map(input_file$clean_html, tokenize)

token_list <-
  input_file %>%
    select(doi_underscore, tokens) %>%
    unnest(cols = tokens)


write_csv(token_list, file = output_file)


