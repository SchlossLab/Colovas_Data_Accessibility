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

#here will need map statement to webscrape for each doi, and then a mutate to add it to the df as a column with the text in it
#does it need a map or just a mutate? 

# mutate(data,
#        paper_html = webscrape(data$paper))


#Function for token counting pipeline (from TidyingText.R)
create_tokens <- function(html_text, min_word_length = 3) {
  html_text %>%
    as_tibble() %>% 
    unnest_tokens(word, value) %>% 
    arrange() %>% 
    filter(nchar(word) > min_word_length) %>% 
    anti_join(., stop_words, by = "word") %>% 
    count(word)
}

prepare_data <- function(data, file_path = "Data/data.json", n_tokens = 1)
{
  json_data <- 0
  df <- 0
  if(file.exists(file_path))
  {
    json_data <- fromJSON(file_path)
    tibble_data <- lapply(json_data$html_text,
                       create_tokens)
    df <- data.frame(json_data$paper, json_data$html_text, tibble_data)
  }
  else
  {
    webscraped_data <- lapply(data$paper, webscrape)
    tibble_data <- lapply(webscraped_data, create_tokens)
    df <- data.frame(data$paper, webscraped_data
    , tibble_data)
  }
  json_data <- toJSON(df)
  save(json_data, file=file_path)
  return (json_data)
}

gt_subset_30 <- read_csv("Data/gt_subset_30.csv")
prepare_data(gt_subset_30)

test1_url <- "https-::journals.asm.org:doi:10.1128:aac.47.7.2125-2130.2003.html"

