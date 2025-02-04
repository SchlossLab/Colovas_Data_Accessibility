#!/usr/bin/env Rscript
#20250204 - doi gathering with rentrez to access ncbi
#
#
#library statements 
library(tidyverse)
library(rentrez)

#look at searchable parts of pubmed
pubmed <- entrez_db_searchable("pubmed")
pubmed$ISBN

issn <- "1935-7885" #jmbe
ncbi_key <-"fb31376a19d721e1c68199bbe6fae7cb7f08"

#practice run 
query <-"1935-7885[ISBN]"
search <- entrez_search("pubmed", rettype = "json", 
                        term = issn, retmax = 100, use_history = TRUE)
str(search)

search$QueryTranslation
search$file
search$web_history

fetch <-entrez_fetch("pubmed", web_history = search$web_history, rettype = "json")
str(fetch)
