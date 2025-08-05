#!/usr/bin/env Rscript
#create df of links to check with removed punctuation at the end 
#
#
#
#library statements
library(tidyverse)
library(httr2)
# library(rvest)
# library(xml2)
# library(tidytext)
# library(jsonlite)



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

get_site_status_no_follow <-function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = FALSE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

#is it the mutate causing problems? - maybe- certainly faster than map
punct <-punct %>%
    mutate(no_punct_status = get_site_status(no_punct), 
            reg_no_follow_status = get_site_status_no_follow(link_address),
             no_punct_no_follow_status = get_site_status_no_follow(no_punct),
            regular_status = get_site_status(link_address))


punct_30<-punct[1:30,]
punct_30$og_no_mutate_no_follow <-map(punct_30$link_address, get_site_status_no_follow)

punct %>% count(no_punct_status, reg_no_follow_status, no_punct_no_follow_status, regular_status)

umich_test <-c(link_status = get_site_status("umich.edu"), 
                no_follow = get_site_status_no_follow("umich.edu"))

conda_test <-c(link_status = get_site_status("https://anaconda.org/search?q=httpgd"), 
                no_follow = get_site_status_no_follow("https://anaconda.org/search?q=httpgd"))

githubt_test <-c(link_status = get_site_status("https://github.com/tidyverse/tidyverse"), 
                no_follow = get_site_status_no_follow("https://github.com/tidyverse/tidyverse"))

#why are all of them 404 errors? that is what i don't understand - do they need to be run on the cluster? 

punct %>% count(no_punct_status, no_follow_status, regular_status) %>% view()

write_csv(punct, file = "Data/linkrot_datasets/no_punctuation.csv.gz")


#and now looking at it once it's been processed
still_rotten<-read_csv("Data/linkrot_datasets/no_punctuation.csv.gz")

still_rotten %>% 
   count(link_status, no_punct_status)


#20250606 - making sure the linkrot works the way we want it to 
#ok something is wrong with this i don't think the mutate works right instead of the map which is slow? 
#need to test it on monday 