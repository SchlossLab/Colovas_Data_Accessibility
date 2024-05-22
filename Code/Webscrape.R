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

  webscraped_data <-  map_chr(data$paper, webscrape)

  df <- tibble::tibble(paper_doi = data$paper, 
                      paper_html = webscraped_data)

  write.csv(df, file = file_path_gz, row.names = FALSE)
}

# call function for snakemake use
dataset <- read_csv(input_file)
webscrape_save_html(dataset, output_file)


# call function on small dataset

#gt_ss30 <- read_csv("Data/gt_subset_30.csv")
#webscrape_save_html(gt_ss30, "Data/gt_subset_30_data.csv.gz")


# call function on larger dataset

#groundtruth <- read_csv("Data/groundtruth.csv")
#webscrape_save_html(groundtruth, "Data/groundtruth.csv.gz")

