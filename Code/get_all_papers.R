#!/usr/bin/env Rscript
# get_all_papers.R
#
#
#
# library statements
library(tidyverse)
library(tidytext)

# snakemake input 
#  {input.rscript} {params.dir} {output}
input <- commandArgs(trailingOnly = TRUE)
papers_dir <- input[1]
output <- input[2]


# local practice 
# papers_dir <- "Data/papers"
# output<-"Data/papers/all_papers.csv.gz"

csv_files <- list.files(papers_dir, "*.csv")


all_papers <- tribble(~paper, ~unique_id)

for (i in 1:12) {
    csv_file <- read_csv(paste0(papers_dir, "/", csv_files[i])) %>%
        select(., c(paper, unique_id))
    all_papers <- full_join(all_papers, csv_file)
}

all_papers <-
    all_papers %>%
        rename(url = paper, doi = unique_id)

write_csv(all_papers, file = output)


#20250212 - i have no idea why this was set up for snakemake, but i need to use it to get all crossref dois again

#let's see what this one looks like 
all_papers <-read_csv("Data/papers/all_papers.csv.gz")

papers <- read_csv("Data/crossref/crossref_all_papers.csv.gz") 
papers <- papers %>%
    mutate(doi_underscore = str_replace(doi, "/", "_"), 
            paper = paste0("https://journals.asm.org/doi/", doi))

#make doi list like all_papers
doi_list <- papers %>% 
    select(paper, doi_underscore) %>% 
    rename(url = paper, doi = doi_underscore)

write_csv(doi_list, "Data/crossref/all_papers_dois.csv.gz")

#20250212 - get all dois after filtering them 
#load files
scopus <-read_csv("Data/scopus/all_scopus_citations.csv.gz")

crossref <-read_csv("Data/crossref/crossref_all_papers.csv.gz")

ncbi <-read_csv("Data/ncbi/ncbi_all_papers.csv.gz")

wos <-read_csv("Data/wos/wos_all_papers.csv.gz")

#fix up ncbi
ncbi <-ncbi %>%
filter(!is.na(doi))

dupes<- which(duplicated(ncbi$doi))
dupe_table <- rbind(ncbi[dupes,])
ncbi <-anti_join(ncbi, dupe_table)

#filter na scopus
scopus <-
scopus %>%
filter(!is.na(`prism:doi`))

#remove pre-y2k for scopus 12927
scopus <-
    scopus %>%
    filter(!str_detect(`prism:doi`, "19\\d\\d$")) 

#filter na wos
wos <-
wos %>%
filter(!is.na(doi))

#make them all lowercase
ncbi$doi <- tolower(ncbi$doi)
scopus$`prism:doi` <-tolower(scopus$`prism:doi`)
crossref$doi<-tolower(crossref$doi)
wos$doi <- tolower(wos$doi)

#unique on wos$doi and removing wos dupes
unique(wos$doi)

wos_dupes<- which(duplicated(wos$doi))
wos_dupe_table <- rbind(wos[wos_dupes,])
wos <-anti_join(wos, wos_dupe_table)


#join all datasets 

full_joined <-full_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
    full_join(., ncbi, by = join_by(`prism:doi` == doi)) %>%
    full_join(., wos, by = join_by(`prism:doi` == doi))


all_dois<-c(scopus$`prism:doi`, crossref$doi, ncbi$doi, wos$doi)
head(all_dois)

str(all_dois) 
grep("10.1128/\\d", all_dois) # this one is 0
grep("10.1128/\\.", all_dois, value = TRUE)

unique_dois <-tibble(all_dois) %>% 
    filter(!str_detect("10.1128/\\.", all_dois) & !str_detect("10.1128/\\d", all_dois)) %>%
    unique()

renamed <-
unique_dois %>%
     mutate(doi_underscore = str_replace(all_dois, "/", "_"), 
            paper = paste0("https://journals.asm.org/doi/", all_dois)) %>%
    rename(url = paper, doi = doi_underscore) %>% 
    select(url, doi)

write_csv(renamed, "Data/all_api_dois.csv.gz")
