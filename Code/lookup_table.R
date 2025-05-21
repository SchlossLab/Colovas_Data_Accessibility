#!/usr/bin/env Rscript
#
#
#library statements
library(tidyverse)


#20250306 - new lookup table for the new doi set

#load files that might help me
all_dois <-read_csv("Data/all_api_dois.csv.gz")%>%
    mutate(doi_no_underscore = str_replace(doi, "_", "\\/"))

# all_dois %>% 
#     filter(str_detect(url, "genome"))  %>% 
#     view()

crossref <-read_csv("Data/crossref/crossref_all_papers.csv.gz")
# crossref %>% 
#     filter(str_detect(doi, "genome"))  %>% 
#     view()


#get the container title for all of these papers and --------------------
#throw out garbage dois without right formatting
container.title <- crossref %>%
    count(container.title) %>% 
    select(container.title)
    
j_table<- tibble(
    journal_abrev = c("aac", "aem", "genomea", "iai", "jb", "jcm", "jmbe", 
    "jmbe", "jvi", "mra", "spectrum", "mbio", "msphere", "msystems"), 
    container.title
)

#20250306 - lookup table cols 
#paper - https://journals.asm.org/doi/DOI
#html_filename - Data/html/DOI_underscore
#container.title - Journal of Whatever
#predicted - "Data/predicted/10.1128_jb.masthead.203-18.csv"


#get all journal names so that it all goes smoothly 
lookup_table<-
all_dois %>%
    mutate(journal_abrev = str_split_i(doi, "_", 2)) %>%
    mutate(journal_abrev = str_split_i(journal_abrev, "\\.", 1)) %>% 
    left_join(., j_table, by = join_by(journal_abrev), 
                relationship = "many-to-many" ) %>% 
    filter(!is.na(container.title))

# lookup_table %>%
# #     # count(container.title)
#     filter(str_detect(url, "genome"))

lookup_table<-
lookup_table %>%
    rename(paper = url) %>%
    mutate(html_filename = paste0("Data/html/", doi, ".html"), 
        predicted = paste0("Data/predicted/", doi, ".csv"))

# # #we have mra/ga here
# lookup_table %>%
#   filter(str_detect(paper, "genome"))  %>%
#   view()


write_csv(lookup_table, file = "Data/all_dois_lookup_table.csv.gz")



