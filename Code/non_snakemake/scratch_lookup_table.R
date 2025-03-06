# no shebang, doesn't need to be run on the cluster
#
#
#library statements
library(tidyverse)

#need to import all the metadata files
papers_dir <- "Data/papers"
csv_files <- list.files(papers_dir, "*.csv")


all_papers <- tribble(~paper, ~html_filename, ~container.title)

for (i in 1:12) {
    csv_file <- read_csv(paste0(papers_dir, "/", csv_files[i])) %>%
        select(., c(`paper`, `container.title`, `html_filename`))
    all_papers <- full_join(all_papers, csv_file)
}

all_papers<-
    all_papers %>%
    mutate(predicted = paste0("Data/predicted/", str_split_i(html_filename, "/", 3), ".csv"), 
    html_filename = paste0(html_filename, ".html"))

write_csv(all_papers, file = "Data/papers/lookup_table.csv.gz")


#20250306 - new lookup table for the new doi set

#load files that might help me
all_dois <-read_csv("Data/all_api_dois.csv.gz")%>%
    mutate(doi_no_underscore = str_replace(doi, "_", "\\/"))
scopus <-read_csv("Data/scopus/all_scopus_citations.csv.gz")
crossref <-read_csv("Data/crossref/crossref_all_papers.csv.gz")
ncbi <-read_csv("Data/ncbi/ncbi_all_papers.csv.gz")
wos <-read_csv("Data/wos/wos_all_papers.csv.gz")

#get the container title for all of these papers and --------------------
#throw out garbage dois without right formatting
container.title <- crossref %>%
    count(container.title) %>% 
    select(container.title)
    
j_table<- tibble(
    journal_abrev = c("aac", "aem", "iai", "jb", "jcm", "jmbe", 
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


lookup_table<-
lookup_table %>%
    rename(paper = url) %>%
    mutate(html_filename = paste0("Data/html/", doi, ".html"), 
        predicted = paste0("Data/predicted/", doi, ".csv"))


write_csv(lookup_table, file = "Data/all_dois_lookup_table.csv.gz")



