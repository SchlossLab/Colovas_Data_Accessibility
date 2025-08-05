#!/usr/bin/env Rscript
# utilities.R
# script with commonly used functions across multiple R script files
#
#library statements 
library(tidyverse)
library(rvest)
# library(tidytext) #20250411 - i actually don't think we need tidytext
library(xml2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(tokenizers)

webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  side_panel<-read_html(doi) %>% 
    html_elements("#core-collateral-info")
  
  
  paper_html <- paste0(abstract, body, side_panel, collapse = " ") 
  
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
