#!/usr/bin/env Rscript

# cleanHTML.R
# take webscraped HTML and clean html tags 
#
#
# load packages
library(tidyverse)
library(tidytext)
library(xml2)
library(rvest)
library(textstem) #for stemming text variables
library(tm) #for text manipulation

input <- commandArgs(trailingOnly = TRUE)
html <- input[1]
output_file <- input[2]


# function to prep HTML using package tm
prep_html_tm <- function(html) {
  html <- as.character(html)
  html <- read_html(html) %>% html_text()
  html <- stripWhitespace(html)
  html <- removeNumbers(html)
  html <- removePunctuation(html)
  html <- lemmatize_strings(html)
}

# 20240521 - need to update this with more accurate snakefiles
webscraped_data <- read.csv(html)
webscraped_data$clean_html <- lapply(webscraped_data$paper_html, prep_html_tm)
webscraped_data <- select(webscraped_data, !"paper_html")
webscraped_data$clean_html <- 
  map_chr(webscraped_data$clean_html, as.character)
write.csv(webscraped_data, 
          file = output_file, 
          row.names = FALSE)

# # ground truth ss30
# webscraped_data <- read.csv("Data/gt_subset_30_data.csv.gz")
# webscraped_data$clean_html <- lapply(webscraped_data$paper_html, prep_html_tm)
# webscraped_data <- select(webscraped_data, !"paper_html")
# webscraped_data$clean_html <- 
#  map_chr(webscraped_data$clean_html, as.character)
# write.csv(webscraped_data, 
#          file = "Data/gt_subset_30_clean_html.csv.gz", 
#          row.names = FALSE)

# # groundtruth 
# #webscraped_data <- read.csv("Data/groundtruth.csv.gz")
# webscraped_data$clean_html <- lapply(webscraped_data$paper_html, prep_html_tm)
# webscraped_data <- select(webscraped_data, !"paper_html")
# webscraped_data$clean_html <- 
#   map_chr(webscraped_data$clean_html, as.character)
# write.csv(webscraped_data, 
#           file = "Data/groundtruth_clean_html.csv.gz", 
#           row.names = FALSE)
