#!/usr/bin/env Rscript
#
# download_page.R
# take paper DOI and download entire page into folder
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)
library(htmltools)
library(httr2)

# #command line inputs
# input <- commandArgs(trailingOnly = TRUE)
# input_file <- input[1]
# output_file <- input[2]

# local input
input_file <- read_csv("Data/doi_linkrot/alive/1935-7885.csv")
# colnames(input_file)
output <- "Data/html/1935-7885/"


## 20241112 - took this from doi_linkrot 
# get_site_status_no_follow <- function(websiteurl) {
  
#   response <- tryCatch( {request(websiteurl) %>% 
#       req_options(followlocation = FALSE) %>%
#       req_error(is_error = ~ FALSE) %>% 
#       req_perform()}, error = \(x){list(status_code = 404) } )
  
#   numeric_response <- response$status_code
#   html <- response$html
#   return(numeric_response)
  
# }

# add unique_id to table to tell you what the filename will be
input_file <- input_file %>% 
    mutate(unique_id = str_split_i(input_file$doi, "/", 2))

# start loop to go through each paper and save output
input_file_small <- 
  slice_head(input_file, n = 20) %>%
  mutate(link_status = as.numeric(0)) 

str(input_file_small$link_status)


download_html <- function(input_file) {
  for(i in 1:nrow(input_file)){
    response <- tryCatch( {request(input_file$paper[i]) %>% 
        req_options(followlocation = FALSE) %>%
        req_error(is_error = ~ FALSE) %>% 
        req_perform()}, error = \(x){list(status_code = 404) } )

      input_file$link_status[i] <- as.numeric(response$status_code)
      html <- response %>% resp_body_html()
      filename <- paste0(output, input_file_small$unique_id[i], ".html")

      write_html(html, file = filename)
  }
}

#~14 seconds for 20 files 
download_html(input_file_small)


# see pat note and ask greg for help with snakemake rules 