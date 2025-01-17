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
scopus_req <- request(paste0("https://api.clarivate.com/apis/wos-starter/v1/journals/IS=", 
                            issn)) %>%
    req_headers("X-ApiKey" = clarivate_key)

scopus_response <- req_perform(scopus_req) %>%
    resp_body_json(simplifyVector = TRUE) 
