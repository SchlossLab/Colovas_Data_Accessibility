#!/usr/bin/env Rscript
#20250204 - doi gathering with rentrez to access ncbi
#
#
#library statements 
library(tidyverse)
library(rentrez)
library(xml2)


#snakemake
input <- commandArgs(trailingOnly = TRUE)
issn <- as.character(input[1])

#local testing
issn <- "1098-5522" #I&I

ncbi_key <-"fb31376a19d721e1c68199bbe6fae7cb7f08"

#20250204 practice run - this works to get a list of things

entrez_db_searchable("pubmed")

# search <- entrez_search("pubmed", rettype = "json", 
#                         term = issn, retmax = 10000, use_history = TRUE)


search <- entrez_search("pubmed", rettype = "json", 
                        term = "1098-5522[issn]+AND+20000101[mindate]+AND+20250101[maxdate]", 
                        retmax = 1000, use_history = TRUE, retstart = 1000)

search$web_history

#20250205- fetches 10K, but how do i get the rest of them
fetch <-entrez_fetch("pubmed", web_history = search$web_history, rettype = "csv")

columns <- c("UID", "title", "authors", "citation_info", "first_author", "journal_name",
 "pub_year", "pub_date", "NA", "NA", "doi")

fetched_csv <-read_csv(fetch, col_names = columns)

write_csv(fetched_csv, file = paste0("Data/ncbi/ncbi_", issn, ".csv.gz"))


