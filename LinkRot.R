#begin link rot, extract links from pre-scraped website html
#
#
#library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(jsonlite)
library(crul)
#rvest imports these as dependencies
#library(tibble)
#library(xml2)

#load data function from json file 
#read and de-serialize json 



#extract links from pre-scraped html
extract_links <- function(file_path) {
 #this works to get the data out of the json format 
  json_data <- read_json(file_path)
  json_data <- unserializeJSON(json_data[[1]])
  json_unserialized <- tibble(paper = json_data$`data$paper`, 
                       text = paste(json_data$webscraped_data))
  

  #actually doing anything with the paper texts does not
  json_link <- map(json_unserialized$text, html_elements, css = "a")
  
  links <- read_html(json_unserialized$text) %>% 
    html_elements(css = "a") %>% 
    tibble()
  
  return(links)
  
}



