#!/usr/bin/env Rscript
#create df of links to check with removed punctuation at the end 
#
#
#
#library statements
library(tidyverse)
library(httr2)

#read in linkrot file 
linkrot<-read_csv("Data/final/linkrot_combined.csv.gz") 

#12045 links ending with punctuation/ and not 200 status (link OK)
punctuation <-linkrot %>%
    filter(str_ends(link_address, "\\.") | str_ends(link_address, "\\)")) %>% # remove only terminal . and )
    filter(!str_detect(link_address, "\\(")) %>% #exclude anything with an open (
    filter(link_status != 200)


#remove the final punctuation
punctuation <-punctuation %>%
    mutate(no_punctuation = str_sub(link_address, start = 1, end = -2)) 

#from linkrot - original function that follows links 
# 20250624 - we don't really care in a functional sense if we're redirected
get_site_status <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = TRUE) %>% # this line 'follows' links that redirect the user, 
      req_error(is_error = ~ FALSE) %>% 
      req_retry(retry_on_failure = FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}



punctuation_map <-punctuation %>%
    mutate(no_punctuation_status = map_dbl(no_punctuation, get_site_status))

punctuation_map %>% count(link_status, no_punctuation_status)

write_csv(punctuation_map, file = "Data/linkrot_datasets/no_punctuation_status.csv")

