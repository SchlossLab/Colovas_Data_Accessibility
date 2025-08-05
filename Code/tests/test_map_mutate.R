#testing map vs mutate on linkrot stuff

#library statements
library(tidyverse)
library(httr2)


linkrot<-read_csv("Data/final/linkrot_combined.csv.gz")
head(linkrot)

punct <-linkrot %>%
    filter(str_ends(link_address, "\\.")| str_ends(link_address, "\\,") | str_ends(link_address, "\\;") 
    | str_ends(link_address, "\\:") | str_ends(link_address, "\\(") | str_ends(link_address, "\\)") | str_ends(link_address, "[:punct:]")) %>%
    filter(link_status != 200)

checks <- linkrot %>%
    filter(str_ends(link_address, "\\.")| str_ends(link_address, "\\,") | str_ends(link_address, "\\;") 
    | str_ends(link_address, "\\:") | str_ends(link_address, "\\(") | str_ends(link_address, "\\)") | str_ends(link_address, "[:punct:]")) %>%
    filter(link_status == 200)

punct <-punct %>%
    mutate(no_punct = str_sub(link_address, start = 1, end = -2)) 

checks <-checks %>%
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

#from linkrot 
get_site_status_no_follow <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = FALSE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  return(numeric_response)
  
}

punct <-punct %>%
    mutate(no_punct_status = get_site_status(no_punct), 
            no_punct_no_follow_status = get_site_status_no_follow(no_punct), 
            og_link_status = get_site_status(link_address), 
            og_link_no_follow = get_site_status_no_follow(link_address))


checks <-checks %>%
    mutate(no_punct_status = get_site_status(no_punct), 
            no_punct_no_follow_status = get_site_status_no_follow(no_punct), 
            og_link_status = get_site_status(link_address), 
            og_link_no_follow = get_site_status_no_follow(link_address))

punct %>% 
    count(link_status, no_punct_status, no_punct_no_follow_status, og_link_status, og_link_no_follow) %>% 
    View()

checks %>% 
    count(link_status, no_punct_status, no_punct_no_follow_status, og_link_status, og_link_no_follow) %>% 
    View()


#ok here we look at map vs mutate with a smaller dataset
 
punct_30 <-punct[1:30, ]
punct_5<-punct[1:5, ]

punct <-punct %>%
    mutate(no_punct_status = map(no_punct, get_site_status))

#well no wonder this doesn't work, the benchmark says the map takes 786 mins....
microbenchmark(mutate(punct_5, no_punct_status = get_site_status(no_punct)), mutate(punct_5, no_punct_status = map(no_punct, get_site_status)))

#what about a for loop 

for (i in 1:nrow(punct_5)) {
    punct_5$no_punct_status <-get_site_status(punct_5$no_punct)
}

count(punct_5, no_punct_status)

#i have no idea what's wrong with this and why it's not working? 
