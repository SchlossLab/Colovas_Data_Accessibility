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
input <- commandArgs(trailingOnly = TRUE)
input_file <- input[1]
output <- input[2]

# # local input
input_file <- read_csv("Data/papers/1935-7885.csv")
# colnames(input_file)
output <- "Data/html/1935-7885/"


# small table for local testing
input_file_small <- 
  slice_head(input_file, n = 20) 


# start loop to go through each paper and save output

download_html <- function(input_file) {
  for(i in 1:nrow(input_file)){
    response <- tryCatch( {request(input_file$paper[i]) %>% 
        req_options(followlocation = FALSE) %>%
        req_error(is_error = ~ FALSE) %>% 
        req_perform()}, error = \(x){list(status_code = 404) } )
       
    html <- "NA"

    if(response$status_code != 404) {
        html <- response %>% resp_body_html()
      }

      input_file$html_link_status[i] <- as.numeric(response$status_code)

#20241114 - write_html will actually only write html files, 
#need to find something to put in file if it's empty
#can we write if there's nothing in html? 
# can we find some with 404 errors to test? use data/papers/dead/files for 404s

      write_html(html, file = input_file$html_filename[[i]])
  }
}

#okay do webscraping!
download_html(input_file) #big one
download_html(input_file_small) #small one


#20241114 - for testing purposes only in the loop 
i<-1
response <- tryCatch( {request(input_file_small$paper[i]) %>% 
        req_options(followlocation = FALSE) %>%
        req_error(is_error = ~ FALSE) %>% 
        req_perform()}, error = \(x){list(status_code = 404) } )
        input_file_small$link_status[i] <- as.numeric(response$status_code)
        html <- NA
      if(response$status_code != 404) {
         html <- response %>% resp_body_html()
      }
      write_html(html, file = input_file$filename[i])

      head(response$body)
      
str(html)
