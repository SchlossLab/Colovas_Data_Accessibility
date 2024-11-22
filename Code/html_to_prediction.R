#!/usr/bin/env Rscript
#take scraped html and end with a tibble of predictions
#
#
#
# library statements
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)
library(textstem) #for stemming text variables
library(tm) #for text manipulation
library(data.table)

#read in list of html files from filepath
# pat said do all of them at once...which means they
# all need to be scraped before this 
# test with a group of 5 or something


#snakemake 
input <- commandArgs(trailingOnly = TRUE)
input_file <- read.table(input[1])  %>% 
    select(paper, html_filename) %>%
    mutate(clean_html = NA)
input_path <- input[2]
output_file <- input[3]


#20241122 local input
# all_html_files <- 
ten_html_files <- head(list.files("Data/html/"))


#start with making a data.table for all the files
output_table <- data.table(html_filename = ten_html_files)

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

# function to prep HTML using package tm
prep_html_tm <- function(html) {
  html <- as.character(html)
  html <- read_html(html) %>% html_text()
  html <- str_to_lower(html)
  html <- stripWhitespace(html)
  html <- removePunctuation(html)
  html <- str_remove_all(html, "[[:digit:]]")
  html <- str_remove_all(html, "[[^a-z ]]")
  html <- lemmatize_strings(html)
}

# #20241122- iteration for a small function 
# #may or may not need this function, 
# #not the best to iterate through like this
# for (i in 1:nrow(input_file)) {
#     if(!file.exists(input_file$html_filename[[i]])) {
#         next
#     }
#    html <- webscrape(input_file$html_filename[[i]])
#    html <- prep_html_tm(html)
#    input_file$clean_html[[i]] <- html
    
# }


webscrape_1 <-webscrape(paste0("Data/html/", ten_html_files[1]))







