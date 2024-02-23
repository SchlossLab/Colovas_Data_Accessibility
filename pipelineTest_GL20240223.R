# GL test script for smaller subset (N=30) of groundtruth (gt_subset_30)
#goals: read html, removal of figures and tables, save html, tokenize paper, send each thing to a json file

#library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(tibble)
library(xml2)
library(jsonlite)

#load data
gt_subset_30 <- read_csv("Data/gt_subset_30.csv")

#function for reading html, remove figs/tables, and concatenate abstract and body (using rvest, xml2)
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
  
  paper_html <- paste(abstract, body) %>% tibble()
  
  return(paper_html)
  
}

#here will need map statement to webscrape for each doi, and then a mutate to add it to the df as a column with the text in it
#does it need a map or just a mutate? 

mutate(gt_subset_30, 
       paper_html = webscrape(gt_subset_30$paper))


#Function for token counting pipeline (from TidyingText.R)
count_words <- function(file_name, min_word_length = 3) {
  readLines(file_name) %>% 
    as_tibble() %>% 
    unnest_tokens(word, value) %>% 
    arrange() %>% 
    filter(nchar(word) > min_word_length) %>% 
    anti_join(., stop_words, by = "word") %>% 
    count(word)
}
