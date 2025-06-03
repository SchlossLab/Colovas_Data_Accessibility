#!/usr/bin/env Rscript
#create df of links to check with removed punctuation at the end 
#
#
#
#library statements
library(tidyverse)
library(httr2)


linkrot<-read_csv("Data/final/linkrot_combined.csv.gz")
head(linkrot)

punct <-linkrot %>%
    filter(str_ends(link_address, "\\.")| str_ends(link_address, "\\,") | str_ends(link_address, "\\;") 
    | str_ends(link_address, "\\:") | str_ends(link_address, "\\(") | str_ends(link_address, "\\)") | str_ends(link_address, "[:punct:]")) %>%
    filter(link_status != 200)

punct <-punct %>%
    mutate(no_punct = str_sub(link_address, start = 1, end = -2)) 

#from linkrot 
get_site_status <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = TRUE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

punct <-punct %>%
    mutate(no_punct_status = get_site_status(no_punct))

write_csv(punct, file = "Data/linkrot_datasets/no_punctuation.csv.gz")


#and now looking at it once it's been processed
still_rotten<-read_csv("Data/linkrot_datasets/no_punctuation.csv.gz")

still_rotten %>% 
   count(link_status, no_punct_status)
