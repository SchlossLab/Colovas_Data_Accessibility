# trying to figure out what's wrong with my webscrape jobs
#20241030
#
#
#library calls
library(tidyverse)
library(rvest)
library(tidytext)
library(xml2)

#more library calls from doi_linkrot
library(jsonlite)
library(httr2)

#scrape fails at index 12983
failed_scrape <- read_csv("Data/doi_linkrot/alive/1098-5514.csv")
colnames(failed_scrape)

failed_doi  <- failed_scrape$paper[12983]
failed_doi
