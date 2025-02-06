#!/usr/bin/env Rscript
#20250206 - opening of edirect files 
#
#
#library
library(tidyverse)
library(xml2)


#filename 
filename <- "1098-5522_efetch.csv"
columns <- c("UID", "title", "authors", "citation_info", "first_author", "journal_name",
 "pub_year", "pub_date", "NA", "NA", "doi")

file_import <-read_csv(filename, col_names = columns )

file_import %>%  
    filter(pub_year >=2000 & pub_year <= 2024) %>% 
    count(pub_year)

view(head(file_import))
