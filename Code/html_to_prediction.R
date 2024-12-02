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

#collapse correlated variables for z scoring
collapse_correlated <- function(token_tibble) {
  tokens_to_collapse <-read_csv("Data/ml_prep/tokens_to_collapse.csv")
  any(tokens_to_collapse %in% token_tibble)
  for(i in 1:nrow(token_tibble)){
    for(j in 1:nrow(tokens_to_collapse)){
      if (token_tibble$tokens[i] == tokens_to_collapse$tokens[j]){
        token_tibble$tokens[i] <-tokens_to_collapse$grpname[j]
      } 
    }
  }
  any(tokens_to_collapse %in% token_tibble)
  return(token_tibble)
}






#20241126 - from ml_prep_predict
#you can't remove near zero variants from things that only
# appear in one paper, but also it shouldn't really matter
#need to add the journal name (cotainer.title)
# also need to collapse the duplicate tokens

#ok first join to the ztable to find missing tokens
#how different are the ztables?
token_list <- readRDS("Data/ml_prep/groundtruth.data_availability.tokenlist.RDS")
# un_ztable <- read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable.csv")
ztable <- read_csv("Data/ml_prep/groundtruth.data_availability.zscoretable_filtered.csv")


#add missing back into the first table (need to update)





total_pipeline<-function(filename){
  index <- grep(filename, lookup_table$html_filename)
  container.title <-lookup_table$container.title[index]
  update_journal <-paste0("container.title_", container.title)

  webscrape <- webscrape(filename)

  clean_html <- prep_html_tm(webscrape)

  tokens <- tokenize(clean_html) 

  collapsed <-collapse_correlated(tokens) 
    
  #continue filtering for z scoring
  #get only variables in the model
  all_tokens <- full_join(collapsed, ztable, by = "tokens") %>%
    filter(!is.na(token_mean)) %>%
    replace_na(list(frequency = 0))

  #fill journal name
  
 which(update_journal %in% all_tokens$tokens)
  grep("container", all_tokens$tokens, value = TRUE)

}




#generate files and use on 1 file
# 20241126 - need to figure out how to keep doi with it...
#20241126 - also need to do linkrot in same file bc html is here

# 20241125 - if filesize > 0 

# all_html <- list.files("Data/html", full.names = TRUE)

# some_html <-
#   grep("jmbe", all_html, value = TRUE) %>% 
#   head(20)

# file.size(some_html)

# how to keep html with container title 
# i think loop over the entire table 
lookup_table <-read_csv("Data/papers/lookup_table.csv.gz")



one_html_file <- lookup_table$html_filename[1]

webscrape_1 <- webscrape(one_html_file)

clean_html_1 <- prep_html_tm(webscrape_1)

tokens_1 <- tokenize(clean_html_1) 



