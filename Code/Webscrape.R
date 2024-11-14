#!/usr/bin/env Rscript

# Webscrape.R
# take paper DOI list and webscrape paper HTML 
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)

#command line inputs
input <- commandArgs(trailingOnly = TRUE)
input_file <- input[1]
output_file <- input[2]


# #local testing
# doi <- "Data/html/1935-7885/jmbe.8.1.3-12.2007.html"
# webscrape(doi)

#function for reading html, remove figs/tables, 
#and concatenate abstract and body (using rvest, xml2)
webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]") 
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  body_notables <- body %>%
    html_elements(css = ".table > *") %>%
    html_children() %>%
    xml_remove()
  
  body_nofigures <- body %>%
    html_elements(css = ".figure-wrap > *") %>%
    html_children() %>%
    xml_remove()
  
  paper_html <- paste0(abstract, body, collapse = " ") 
  
  return(paper_html)
  
}


webscrape_save_html <- function(data, file_path_gz){

 #  webscraped_data <-  map_chr(data$paper, webscrape)
#20241107 - trycatching errors with webscraping
 webscraped_data <- tryCatch( {
    map_chr(data$paper, webscrape)}, 
    error = \(x){list(webscraped_data = "NA") } )

  df <- tibble::tibble(paper_doi = data$paper, 
                      paper_html = webscraped_data)

  write.csv(df, file = file_path_gz, row.names = FALSE)
}

# 20241107 - try catch code from LinkRot
#  response <- tryCatch( {request(websiteurl) %>% 
#       req_options(followlocation = TRUE) %>%
#       req_error(is_error = ~ FALSE) %>% 
#       req_perform()}, error = \(x){list(status_code = 404) } )

# call function for snakemake use
dataset <- read_csv(input_file)
webscrape_save_html(dataset, output_file)