# GL test script for smaller subset (N=30) of groundtruth (gt_subset_30)
# goals: read html, removal of figures and tables, save html, tokenize paper, send each thing to a json file
#
#library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(tibble)
library(xml2)
library(jsonlite)
library(textstem) #for stemming text variables
#load data


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
  
  paper_html <- paste(abstract, body) %>% tibble()
  
  return(paper_html)
  
}


#Function for token counting pipeline (from TidyingText.R)
#20240429 - add ngrams arguement, but now you can't filter for stopwords, 
#check this out in Rstudio to see what it looks like in the middle of the process
create_tokens <- function(html_text, min_word_length = 3, ngrams = 1) {
  html_text %>%
  unnest_ngrams(., word, ".", format = "html", n = ngrams) %>% 
    arrange() %>% 
    lemmatize_words() %>% 
    filter(nchar(word) > min_word_length) %>%  
    anti_join(., stop_words, by = "word") %>% 
    count(word)
}


#function to re-tokenize webscraped data by diff number/type of tokens
# 20240326 this doesn't actaully work, create_tokens does not take an n_tokens arguement
retokenize <- function(data, file_path, n_tokens = 1) {
  if(file.exists(file_path)){
      json_data <- read_json(file_path)
      json_data <- unserializeJSON(json_data[[1]])
      json_data$tibble_data <- lapply(json_data$webscraped_data, create_tokens)
  }
  return(json_data)
}


#function for unnesting/unlisting tokens for ml modeling
unlist_tokens <- function(tibble_data){
  map(tibble_data, ~uncount(.x, n)) %>%  
    map(unlist, use.names = FALSE)
}

##-------------test for create_tokens--------------------------------
use_json <- function(jsonfile){
  json_data <- read_json(jsonfile)
  json_data <- unserializeJSON(json_data[[1]])
}

create_tokens_test <- function(html_text, min_word_length = 3, ngrams = 1) {
  html_text %>%
    unnest_ngrams(., word, ".", format = "html", n = ngrams) %>% 
    lemmatize_words() %>% 
    anti_join(., stop_words, by = "word") %>% 
    # arrange() %>% 
    filter(nchar(word) > min_word_length) %>%  
    count(word)
}
json_data <- use_json("Data/gt_subset_30_data.json")


json_tibble <- tibble(paper_doi = json_data$`data$paper`,
                      new_seq_data = json_data$`data$new_seq_data`,
                      availability = json_data$`data$availability`,
                      paper_html = json_data$`webscraped_data`)

#fixed unnesting 20240416
json_tibble <- unnest_wider(json_tibble, paper_html, names_sep = "") %>% 
  unnest_wider(paper_html., names_sep = "") %>% 
  mutate(paper_html = paste0(paper_html.1, paper_html.2)) %>% 
  select(c(-paper_html.1, -paper_html.2))

one_html <- json_tibble$paper_html[[1]]

tokens <- create_tokens_test(one_html, 2, 1)
tokens






#-----------end of test-------------------------------------------------

#function for creating json file of data
#add year published, and journal name 
prepare_data <- function(data, file_path){
 
  webscraped_data <- lapply(data$paper, webscrape)
  tibble_data <- lapply(webscraped_data, create_tokens) 
  unlisted_tokens <- unlist_tokens(tibble_data)
  df <- lst(data$paper, data$new_seq_data, data$availability, 
            webscraped_data, tibble_data, unlisted_tokens)
  
  json_data <- serializeJSON(df, pretty = TRUE)
  write_json(json_data, path = file_path)
  return(json_data)
}


#work on making this a loop so that i don't have to do it 100 times by myself

groundtruth <- read_csv("Data/groundtruth.csv")
prepare_data(groundtruth, "Data/groundtruth.json")

gt_ss30 <- read_csv("Data/gt_subset_30.csv")
prepare_data(gt_ss30, "Data/gt_subset_30_data.json")

#gt_newseq_yes <- read_csv("Data/gt_newseq_yes.csv")
#gt_newseq_no <- read_csv("Data/gt_newseq_no.csv")
#gt_availability_yes <- read_csv("Data/gt_availability_yes.csv")
#gt_availability_no <- read_csv("Data/gt_availability_no.csv")

#prepare_data(gt_newseq_yes, "Data/gt_newseq_yes.json")
#prepare_data(gt_newseq_no, "Data/gt_newseq_no.json")
#prepare_data(gt_availability_yes, "Data/gt_availability_yes.json")
#prepare_data(gt_availability_no, "Data/gt_availability_no.json")





