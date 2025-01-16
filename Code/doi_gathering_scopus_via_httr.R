#!/usr/bin/env Rscript
#20250113 - doi gathering with scopus using httr2
#
#
#library statements 
library(tidyverse)
library(httr2)

#snakemake
input <- commandArgs(trailingOnly = TRUE)
issn <- as.character(input[1])


#local testing
# issn <-"1935-7885"

# scopus API with 2x keys
#   scopus/elsevier 
scopus_key <- "f24a07ed9eea613f729d6469a816966c"
scopus_institutional_token <- "7c25e0e82b37408e45c8da604e824725"




#request for the journal to find out how many records and pages it is 
scopus_req <- request(paste0("http://api.elsevier.com/content/search/scopus?query=issn(", 
                            issn, ")&date(2000-2024)&field=citedby-count,prism:doi,date")) %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token)

scopus_response <- req_perform(scopus_req) %>%
    resp_body_json(simplifyVector = TRUE) 

num_responses<- as.numeric(scopus_response$`search-results`$`opensearch:totalResults`)
num_pages <- (num_responses%/%200)

#construcuor for the list
page_results <- vector(mode = "list", length = num_pages+1)
length(page_results)


for(i in 0:num_pages){
if(i == 0){
  request_url<-paste0("http://api.elsevier.com/content/search/scopus?query=issn(", 
                    issn, ")&date(2000-2024)&cursor=*&count=200&field=citedby-count,prism:doi,date&mailto=jocolova@med.umich.edu")
    }
else {
request_url<-cursor_next
}

scopus_req <- request(request_url) %>%
    req_headers("X-ELS-APIKey" = scopus_key) %>%
    req_headers("X-ELS-Insttoken" = scopus_institutional_token) %>%
    req_user_agent("jocolova@med.umich.edu") %>%
    req_throttle(rate = 40/60)

scopus_response <- req_perform(scopus_req) %>%
    resp_body_json(simplifyVector = TRUE) 

cursor_next<-scopus_response$`search-results`$`link`$`@href`[3]

page_results[[i+1]]<-as_tibble(scopus_response$`search-results`$entry)

}

all_results<-tibble(page_results, .name_repair = "minimal") %>% 
    unnest(cols = page_results) 

write_csv(all_results, file = paste0("Data/scopus/scopus_", issn, ".csv.gz"))
