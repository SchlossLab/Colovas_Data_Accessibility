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


punctuation <-linkrot %>%
    filter(str_ends(link_address, "\\.")| str_ends(link_address, "\\,") | str_ends(link_address, "\\;") 
    | str_ends(link_address, "\\:") | str_ends(link_address, "\\(") | str_ends(link_address, "\\)") | str_ends(link_address, "[:punct:]")) %>%
    filter(link_status != 200)

punctuation <-punctuation %>%
    mutate(no_punctuation = str_sub(link_address, start = 1, end = -2)) 

#from linkrot - original function that follows links 
get_site_status <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = TRUE) %>% # this line 'follows' links that redirect the user
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

#want to see if results change if we don't follow links
get_site_status_no_follow <-function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = FALSE) %>%  #this line stops 'following' links that redirect the user
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

#test links we know work 
umich_test <-c(link_status = get_site_status("umich.edu"), 
                no_follow = get_site_status_no_follow("umich.edu"))
umich_test

conda_test <-c(link_status = get_site_status("https://anaconda.org/search?q=httpgd"), 
                no_follow = get_site_status_no_follow("https://anaconda.org/search?q=httpgd"))
conda_test

githubt_test <-c(link_status = get_site_status("https://github.com/tidyverse/tidyverse"), 
                no_follow = get_site_status_no_follow("https://github.com/tidyverse/tidyverse"))
githubt_test


#is it the mutate causing problems? 
# or is it still iterating through the data appropriately?
punctuation <-punctuation %>%
    mutate(no_punctuation_status = get_site_status(no_punctuation), 
        no_punctuation_no_follow_status = get_site_status_no_follow(no_punctuation),
        reg_no_follow_status = get_site_status_no_follow(link_address),
        regular_status = get_site_status(link_address))


