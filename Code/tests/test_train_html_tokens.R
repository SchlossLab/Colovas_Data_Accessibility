#!/usr/bin/env Rscript
# test for train_html_tokens.R
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
# input <- commandArgs(trailingOnly = TRUE)
# input_file <- read_csv(input[1])  %>% 
#     select(doi_underscore, container.title) %>%
#     mutate(clean_html = NA, 
#           html_filename = paste0("Data/html/", doi_underscore, ".html"), 
#           tokens = NA)
# output_file <- input[2]


#local 
#20250220 - use new_groundtruth to get prepped for model training

# #import new groundtruth to get the html filename 
input_file <- read_csv("Data/new_groundtruth_metadata.csv.gz")  %>% 
    select(doi_underscore, container.title) 


#do this for 10 files for testing 

test_input <-
    input_file[1:10, ] %>%
    mutate(html_filename = paste0("Data/html/", doi_underscore, ".html"),
            old_clean_html = NA, 
            new_clean_html = NA,
            old_tokens = NA,
            new_tokens = NA, 
            old_clean_html_filename = paste0("Data/tests/train_html_tokens/old_", doi_underscore, ".csv"), 
            new_clean_html_filename = paste0("Data/tests/train_html_tokens/new_", doi_underscore, ".csv"))


#function for reading html, remove figs/tables, 
#and concatenate abstract and body (using rvest, xml2)
new_webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  
  paper_html <- paste0(abstract, body, collapse = " ") 
  
  return(paper_html)
  
}

old_webscrape <- function(doi) {
  
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



#original webscrape that excludes tables and figures
for (i in 1:nrow(test_input)) {
    if(!file.exists(test_input$html_filename[[i]])) {
        next
    }
   old_html <- old_webscrape(test_input$html_filename[[i]])
   old_html <- prep_html_tm(old_html)
   test_input$old_clean_html[[i]] <- old_html
   write_lines(old_html, file = test_input$old_clean_html_filename[[i]])

   new_html <- new_webscrape(test_input$html_filename[[i]])
   new_html <- prep_html_tm(new_html)
   test_input$new_clean_html[[i]] <- new_html
   write_lines(new_html, file = test_input$new_clean_html_filename[[i]])
    
}


#about 3 mins
test_input$old_tokens <-map(test_input$old_clean_html, tokenize)
test_input$new_tokens<-map(test_input$new_clean_html, tokenize)

for(i in 1:nrow(test_input)) {
    test_input$n_old_tokens[[i]] <- nrow(test_input$old_tokens[[i]])
    test_input$n_new_tokens[[i]] <- nrow(test_input$new_tokens[[i]])
}

#check that n tokens are different 
test_input %>% 
    select(n_old_tokens, n_new_tokens)

#creating the token lists for the next part of getting ready and then save them to file 

old_token_list <-
  test_input %>%
    select(doi_underscore, old_tokens) %>%
    unnest(cols = old_tokens)
write_csv(old_token_list, file = "Data/tests/train_html_tokens/old_token_list.csv")

new_token_list <-
  test_input %>%
    select(doi_underscore, new_tokens) %>%
    unnest(cols = new_tokens)
write_csv(old_token_list, file = "Data/tests/train_html_tokens/new_token_list.csv")



