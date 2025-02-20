#!/usr/bin/env Rscript
# cleanup_html.R
# clean up pre-saved html
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

#snakemake 
input <- commandArgs(trailingOnly = TRUE)
input_file <- read.table(input[1])  %>% 
    select(paper, html_filename) %>%
    mutate(clean_html = NA)
input_path <- input[2]
output_file <- input[3]


#local 
#20250220 - use new_groundtruth to get prepped for model training


# doi <- "Data/html/10.1128_jmbe.8.1.3-12.2007.html"
# file.exists(doi)
# html<-webscrape(doi)
# clean<- prep_html_tm(html)





#function for reading html, remove figs/tables, 
#and concatenate abstract and body (using rvest, xml2)
webscrape <- function(doi) {
  
  abstract <- read_html(doi) %>%
    html_elements("section#abstract") %>%
    html_elements("[role = paragraph]")
  
  body <- read_html(doi) %>%
    html_elements("section#bodymatter") 
  
  
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

for (i in 1:nrow(input_file)) {
    if(!file.exists(input_file$html_filename[[i]])) {
        next
    }
   html <- webscrape(input_file$html_filename[[i]])
   html <- prep_html_tm(html)
   input_file$clean_html[[i]] <- html
    
}

# remove hmtl_filename we don't need to save it now
input_file <- input_file %>% 
    select(!html_filename)

#remove NAs in clean_html column 


write_csv(input_file, file = output_file)


#how will it work through the rest of the steps
# tokenization - this one is beefy
# prep for prediction - i feel like this one could be better
# prediction - this part is the easy part 
