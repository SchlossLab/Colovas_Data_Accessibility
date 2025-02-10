#!/usr/bin/env Rscript
# DOI gathering 
#
#
#library statements
library(tidyverse)
library(rcrossref)

#snakemake
input <- commandArgs(trailingOnly = TRUE)
issn <- as.character(input[1])

#local testing
issn <-"1935-7885"


 #crossref query
  metadata_list <- cr_journals(issn = issn, 
              works = TRUE,
              sort = "published-print",
              order = "asc",
              cursor_max = 50000,
              cursor = "*", 
              filter = list(from_pub_date = "2000"))
 
#get only metadata part of the list 
metadata <- metadata_list[["data"]]

#filter for 2000-2024 & link has the journal name

as.Date(metadata$published.print)
metadata %>% count(published.print) %>% print(n = Inf)

ymd(metadata$published.print)

metadata %>%
  grep(published.print < "2025-01-01")

#save as an RDS file
write_csv(metadata, paste0("Data/crossref/crossref_", issn, ".csv.gz"))
  


