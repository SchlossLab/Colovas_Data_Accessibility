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
issn <-"1935-7885"

#   clarivate - 
clarivate_key <- "fba06c10b8832254cfed5f514778b86e9f888e51"

#try a request and see what happens
# wos_req <- request(paste0("https://api.clarivate.com/apis/wos-starter/v1/documents/IS=(", 
wos_req <- request(
    "https://api.clarivate.com/apis/wos-starter/v1/documents?db=WOS&q=IS%3D%221935-7885%22&limit=10&page=1&sortField=PY%2BA&modifiedTimeSpan=2000-01-01%2B2025-01-01" )%>% 
  
                            # issn, ")")) %>%
    req_headers("X-ApiKey" = clarivate_key)

wos_response <- req_perform(wos_req) %>%
    resp_body_json(simplifyVector = TRUE) 

view(wos_response)

wos_response 

colnames(wos_response)
str(wos_response)
