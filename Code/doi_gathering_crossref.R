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
#issn <-"1935-7885"


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

#filter for 2000-2024 

metadata <-
  metadata %>%
  mutate(year.published = str_sub(published.print, start = 1, end = 4)) %>%
  filter(year.published <= 2024)

#make sure doi has journal name 

digits<- grep("10.1128/\\d", metadata$doi)
punct<-grep("10.1128/\\.", metadata$doi)
to_remove <-c(digits, punct)

removal_table <-rbind(metadata[to_remove,])
metadata_good_dois<-anti_join(metadata, removal_table)


#save as a csv.gz file
write_csv(metadata_good_dois, paste0("Data/crossref/crossref_", issn, ".csv.gz"))
  


