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
library(httr2)

# #command line inputs
# input <- commandArgs(trailingOnly = TRUE)
# input_file <- input[1]
# output <- input[2]

# # local input
# input_file <- read_csv("Data/doi_linkrot/alive/1935-7885.csv")
# # colnames(input_file)
# output <- "Data/html/1935-7885/"


# small table for local testing
# input_file_small <- 
#   slice_head(input_file, n = 20) 


# start loop to go through each paper and save output

download_html <- function(input_file) {
  for(i in 1:nrow(input_file)){
    response <- tryCatch( {request(input_file$paper[i]) %>% 
        req_options(followlocation = FALSE) %>%
        req_error(is_error = ~ FALSE) %>% 
        req_perform()}, error = \(x){list(status_code = 404) } )

      input_file$link_status[i] <- as.numeric(response$status_code)
      html <- response %>% resp_body_html()

      write_html(html, file = input_file$filename[i])
  }
}

#okay do webscraping!
download_html(input_file) #big one
# download_html(input_file_small) #small one
