#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)

#import data 

papers_dir <- "Data/crossref"
# papers_dir <- "Data/wos"
csv_files <- list.files(papers_dir, "*.csv", full.names = TRUE) 



keep_track<-read_csv(csv_files[2]) %>% 
    # mutate(created = as.character(created))
    mutate_if(lubridate::is.Date, as.character) %>% 
    mutate_if(is.double, as.character, .vars = vars("issue"))

for(i in 3:14) {
    #read in journal
    csv_file <- read_csv(csv_files[i]) %>% 
        mutate_if(lubridate::is.Date, as.character) %>% 
        mutate_if(is.double, as.character, .vars = vars("issue"))
        

    #this does it for the current journal to join with all_papers
    keep_track <- full_join(keep_track, csv_file) 
        
    # keep_track<-bind_rows(keep_track, all_papers)
   
}

#for wos year only 
# keep_track <-
# keep_track %>%
#     filter(as.numeric(publishYear) >= 2000 & as.numeric(publishYear) < 2025)

# write_csv(keep_track, file = "Data/crossref/crossref_all_papers.csv.gz")

# write_csv(keep_track, file = "Data/wos/wos_all_papers.csv.gz")



papers <- keep_track %>%
    mutate(doi_underscore = str_replace(doi, "/", "_"), 
            paper = paste0("https://journals.asm.org/doi/", doi))

write_csv(papers, file = "Data/crossref/crossref_all_papers.csv.gz")

#make doi list like all_papers
doi_list <- papers %>% 
    select(paper, doi_underscore) %>% 
    rename(url = paper, doi = doi_underscore)

write_csv(doi_list, "Data/crossref/all_papers_dois.csv.gz")

#20250429 - get genome announcements data for training set
papers %>%
   filter(container.title == "Genome Announcements") %>% 
   slice_sample(by = year.published, n = 5) %>% 
   write_csv(file = "Data/spot_check/20250429_genome_announcements.csv")


