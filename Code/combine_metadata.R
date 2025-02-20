#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)

#import data 

# papers_dir <- "Data/crossref"
papers_dir <- "Data/wos"
csv_files <- list.files(papers_dir, "*.csv", full.names = TRUE) 



keep_track<-read_csv(csv_files[1]) %>% 
    # mutate(created = as.character(created))
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue"))

for(i in 2:12) {
    #read in journal
    csv_file <- read_csv(csv_files[i]) %>% 
        mutate_if(lubridate::is.Date, as.character) %>% 
        mutate_if(is.double, as.character, .vars = vars("issue"))
        

    #this does it for the current journal to join with all_papers
    keep_track <- full_join(keep_track, csv_file) 
        
    # keep_track<-bind_rows(keep_track, all_papers)
   
}

#for wos year only 
keep_track <-
keep_track %>%
    filter(as.numeric(publishYear) >= 2000 & as.numeric(publishYear) < 2025)

#write_csv(keep_track, file = "Data/crossref/crossref_all_papers.csv.gz")

write_csv(keep_track, file = "Data/wos/wos_all_papers.csv.gz")
