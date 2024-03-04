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



#extract links from pre-scraped html
#extract_links <- function(file_path) {
 #this works to get the data out of the json format 
 # json_data <- read_json(file_path) (commented out for test purposes)
 
 #read and de-serialize json 
 json_data <- read_json("Data/gt_subset_30_data.json") 
 json_data <- unserializeJSON(json_data[[1]])
  
  #turns unserialized data into 2 column dataframe paper, text
  json_unserialized <- tibble(paper = json_data$`data$paper`, 
                       text = paste(json_data$webscraped_data))
  
  #turns unserialized paper text into a readable format and extracts the links into their own two column nested list
  json_unserialized$text <- map(json_unserialized$text, read_html)                   
  json_paper_links <- tibble(paper = json_unserialized$paper, 
                        links = map(json_unserialized$text, html_elements, css = "a"))
  json_paper_links$links <- map(json_paper_links$links, paste0)
 
  #unnests and pivots longer the list of links to have each link as a row with the parent paper
  links_list <- unnest_longer(json_paper_links, col = links)
  
  #extract only papers with 'https' in the link
  links_list_short <- links_list %>% 
    filter(str_detect(links, "https"))
  
  #split links into the link itself, and the text displayed on the website
  links_list_short <- mutate(links_list_short, 
                             link_only = str_split_i(links_list_short$links, "%5C%22", 2), 
                             link_text = str_split_i(links_list_short$links, ">", 2),
                             link_text = str_remove(links_list_short$link_text, "</a"))

#    return(links)
#   
# }



