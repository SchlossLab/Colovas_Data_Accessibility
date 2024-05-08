#begin link rot, extract links from pre-scraped website html
#
#
#library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(jsonlite)
library(httr2)
#rvest imports these as dependencies
#library(tibble)
#library(xml2)

#load data function from json file 
#extract links from pre-scraped html
extract_links <- function(file_path) {

  #read and de-serialize json 
  json_data <- read_json(file_path) 
  json_data <- unserializeJSON(json_data[[1]])
  
  #turns unserialized data into 2 column dataframe paper, text
  json_unserialized <- tibble(paper = json_data$`data$paper`, 
                              text = paste(json_data$webscraped_data))
  
  #turns unserialized paper text into a readable format and extracts the links into their own two column nested list
  json_unserialized$text <- map(json_unserialized$text, read_html)                   
  json_paper_links <- tibble(paper = json_unserialized$paper, 
                             html_tag = map(json_unserialized$text, html_elements, css = "a"))
  json_paper_links$html_tag <- map(json_paper_links$html_tag, paste0)
  
  #unnests and pivots longer the list of links to have each link as a row with the parent paper
  links_list <- unnest_longer(json_paper_links, col = html_tag)
  
  #extract only papers with 'https' in the link
  links_list_short <- links_list %>% 
    filter(str_detect(html_tag, "https"))
  
  #split links into the link itself, and the text displayed on the website
  links_list_short <- mutate(links_list_short, 
                             link_address = str_split_i(links_list_short$html_tag, "%5C%22", 2), 
                             link_text = str_split_i(links_list_short$html_tag, ">", 2))
  
  links_list_short <- mutate(links_list_short, 
                             link_text = str_remove(links_list_short$link_text, "</a"))
 
  #filters for only links with the same text as link address
  links <- links_list_short %>% 
    filter(str_equal(links_list_short$link_address, links_list_short$link_text))
  
  links <- unique(links)
  
  return(links)

}


groundtruth_links <- extract_links("Data/groundtruth.json")
write_csv(groundtruth_links, "Data/groundtruth_links.csv")
link_count <- count(groundtruth_links, by = paper)
link_count <- rename(link_count, paper = "by", link_count = "n")
groundtruth <- read_csv("Data/groundtruth.csv")
groundtruth_linkcount <- left_join(link_count, groundtruth, by = "paper")
write_csv(groundtruth_linkcount, "Data/groundtruth_linkcount.csv")


#function for retrieving the HTML status of a website using httr2 instead of crul 

get_site_status <- function(websiteurl) {

  response <- tryCatch( {request(websiteurl) %>% 
    req_options(followlocation = TRUE) %>%
    req_error(is_error = ~ FALSE) %>% 
    req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}


#load files 
groundtruth_linkcount <- read_csv("Data/groundtruth_linkcount.csv")
groundtruth_links <- read_csv("Data/groundtruth_links.csv")

groundtruth_links$link_status <- map_int(groundtruth_links$link_address, get_site_status)
write_csv(groundtruth_links, "Data/groundtruth_links.csv")
