#!/usr/bin/env Rscript
#20250206 - opening of edirect files 
#
#
#library
library(tidyverse)
library(xml2)


#create all_ncbi files 
filenames<-list.files("Data/ncbi", full.names = TRUE)

columns <- c("UID", "title", "authors", "citation_info", "first_author", "journal_name",
 "pub_year", "pub_date", "NA", "NA", "doi")

all_ncbi <-read_csv(filenames, col_names = columns)

ncbi_eliminated <- all_ncbi %>%  
        filter(pub_year < 2000 | pub_year > 2024) 
       
ncbi_eliminated %>% count(pub_year) %>% print(n = Inf)

ncbi_25 <-
    all_ncbi %>%  
        filter(pub_year >=2000 & pub_year <= 2024) 

write_csv(ncbi_25, file = "Data/ncbi/ncbi_all_papers.csv.gz")
write_csv(ncbi_eliminated, file = "Data/ncbi/ncbi_eliminated_papers.csv.gz")

