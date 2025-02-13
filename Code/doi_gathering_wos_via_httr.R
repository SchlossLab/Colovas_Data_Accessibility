#!/usr/bin/env Rscript
#20250113 - doi gathering with wosr using httr2
#
#
#library statements 
library(tidyverse)
library(httr2)

#snakemake
input <- commandArgs(trailingOnly = TRUE)
issn <- as.character(input[1])


#local testing
issn <-"2379-5042"

#   clarivate - 
clarivate_key <- "fba06c10b8832254cfed5f514778b86e9f888e51"

#request for the journal to find out how many records and pages it is 
wos_req <- request(paste0(
    "https://api.clarivate.com/apis/wos-starter/v1/documents?db=WOS&q=IS%3D%22", 
    issn, 
    "%22&limit=50&page=1&sortField=PY%2BA&modifiedTimeSpan=2000-01-01%2B2025-01-01"))%>% 
    req_headers("X-ApiKey" = clarivate_key)

wos_response <- req_perform(wos_req) %>%
    resp_body_json(simplifyVector = TRUE) 


num_responses<- as.numeric(as.numeric(wos_response$metadata$total))
num_pages <- (num_responses%/%50)

#construcuor for the list
page_results <- vector(mode = "list", length = num_pages)
length(page_results)

#loop structure for all the other results

for(i in 1:num_pages){
request_url<-paste0(
    "https://api.clarivate.com/apis/wos-starter/v1/documents?db=WOS&q=IS%3D%22", 
    issn, 
    "%22&limit=50&page=", i, 
    "&sortField=PY%2BA&modifiedTimeSpan=2000-01-01%2B2025-01-01")
    
wos_req <- request(request_url) %>%
    req_headers("X-ApiKey" = clarivate_key) %>% 
    req_user_agent("jocolova@med.umich.edu") %>%
    req_throttle(rate = 5/60)

wos_response <- req_perform(wos_req) %>%
    resp_body_json(simplifyVector = TRUE) 


page_results[[i]]<-
    tibble(wos_response$hits) %>%
    unnest() 

}

all_results<-tibble(page_results, .name_repair = "minimal") %>% 
    unnest(cols = page_results) %>%
    select(-authors, -pages, -authorKeywords)

write_csv(all_results, file = paste0("Data/wos/wos_", issn, ".csv.gz"))




#playing with stuff
# view(wos_response)

# as.numeric(wos_response$metadata$total)
# tibble(wos_response$hits) %>%
# unnest() %>%
# view()

# colnames(wos_response)
# str(wos_response)
