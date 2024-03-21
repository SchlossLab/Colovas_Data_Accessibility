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
#load data



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


#Function for token counting pipeline (from TidyingText.R)
create_tokens <- function(html_text, min_word_length = 3) {
  html_text %>%
  unnest_tokens(., word, ".", format = "html") %>% 
    arrange() %>% 
    filter(nchar(word) > 3) %>% 
    anti_join(., stop_words, by = "word") %>% 
    count(word)
}


#20240226 if file exists does not retrieve data correctly to update with new tokenization
prepare_data <- function(data, file_path, n_tokens = 1){
  json_data <- 0
  df <- 0
  if(file.exists(file_path))
  {
    json_data <- read_json(file_path)
    json_data <- unserializeJSON(json_data[[1]])
    tibble_data <- lapply("json_data$html_text", create_tokens)
    df <- lst(paper, html_text, tibble_data)
  }
  else
  {
    webscraped_data <- lapply(data$paper, webscrape)
    tibble_data <- lapply(webscraped_data, create_tokens) 
    df <- lst(data$paper, webscraped_data, tibble_data)
  }
  json_data <- serializeJSON(df, pretty = TRUE)
  write_json(json_data, path = file_path)
  return (json_data)
}

#groundtruth <- read_csv("Data/groundtruth.csv")
#prepare_data(groundtruth, "Data/groundtruth.json")

gt_newseq_yes <- read_csv("Data/gt_newseq_yes.csv")
gt_newseq_no <- read_csv("Data/gt_newseq_no.csv")
gt_availability_yes <- read_csv("Data/gt_availability_yes.csv")
gt_availability_no <- read_csv("Data/gt_availability_no.csv")

prepare_data(gt_newseq_yes, "Data/gt_newseq_yes.json")
prepare_data(gt_newseq_no, "Data/gt_newseq_no.json")
prepare_data(gt_availability_yes, "Data/gt_availability_yes.json")
prepare_data(gt_availability_no, "Data/gt_availability_no.json")

gt_ss30 <- read_csv("Data/gt_subset_30.csv")
prepare_data(gt_ss30, "Data/gt_subset_30_data.json" )

#test the half of the prepare_data function for if the file exists
file_path <- "Data/gt_subset_30_data.json"
if(file.exists(file_path))
  json_data <- read_json(file_path)
  json_data <- unserializeJSON(json_data[[1]])
  tibble_data <- map(json_data$html_text, create_tokens) #this line does not work!
  df <- lst(paper, html_text, tibble_data)
