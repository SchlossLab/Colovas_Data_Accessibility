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
library(htmltools)

# #command line inputs
input <- commandArgs(trailingOnly = TRUE)
input_file <- input[1]
output <- input[2]

# # local input
# input_file <- read_csv("Data/papers/1935-7885.csv")
# # colnames(input_file)
# output <- "Data/html/1935-7885/"


# #testing rotted links - 20241115 they work great!
# html_dir <- "Data/html/dead/1935-7885/"
# input_file <- read_csv("Data/doi_linkrot/dead/1935-7885.csv") %>%
#             mutate(unique_id = str_split_i(doi, "/", -1), 
#             html_link_status = as.numeric(0), 
#             html_filename = paste0(html_dir, unique_id, ".html"))


# # small table for local testing
# input_file_small <- 
#   slice_head(input_file, n = 20) 


# start loop to go through each paper and save output

download_html <- function(input_file) {
  for(i in 1:nrow(input_file)){
    response <- tryCatch( {request(input_file$paper[i]) %>% 
        req_options(followlocation = FALSE) %>%
        req_error(is_error = ~ FALSE) %>% 
        req_perform()}, error = \(x){list(status_code = 404) } )

    html <- response %>% resp_body_html()
    

    input_file$html_link_status[i] <- as.numeric(response$status_code)


    write_html(html, file = input_file$html_filename[[i]])
  }
}

#okay do webscraping!
download_html(input_file) #big one
# download_html(input_file_small) #small one
