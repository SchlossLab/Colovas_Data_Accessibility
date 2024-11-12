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
colnames(input_file)


# okay so we're going to do the validity check and scrape in the same thing? 

get_site_status_no_follow <- function(websiteurl) {
  
  response <- tryCatch( {request(websiteurl) %>% 
      req_options(followlocation = FALSE) %>%
      req_error(is_error = ~ FALSE) %>% 
      req_perform()}, error = \(x){list(status_code = 404) } )
  
  numeric_response <- response$status_code
  html <- response$html
  return(numeric_response)
  
}

input_file <- input_file %>% 
    mutate(unique_id = str_split_i(input_file$doi, "/", 2))


view(input_file)

count(input_file, unique_id, sort = TRUE)


# iterate through each doi 

# webscrape and save back to each doi

# how to save all of them as snakemake files and know that it has all the files

one_paper <- input_file$paper[1]
one_doi <- input_file$doi[1]

html <- read_html(one_paper)

#use save_html in htmltools

#have to figure out how to save these, might need just doi or put doi in quotes
htmltools::save_html(html, file = paste0("Data/", one_doi))


#20241112 - try getting status and html in one hit 
#only will work if httr2 is activated

response <- tryCatch( {request(one_paper) %>% 
    req_options(followlocation = FALSE) %>%
    req_error(is_error = ~ FALSE) %>% 
    req_perform()}, error = \(x){list(status_code = 404) } )


  numeric_response <- response$status_code
  html <- response %>% resp_body_html()

# what do i return to let snakemake know i'm done? 