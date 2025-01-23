#see if they have the same citations or not
#
#
#library
library(tidyverse)

#load files
scopus <-read_csv("Data/scopus/all_scopus_citations.csv.gz")

crossref <-read_csv("Data/papers/all_papers.csv.gz") 
crossref <-
    crossref %>% 
        mutate(doi_no_slash = str_replace(doi, "_", "/"))
head(scopus)
head(crossref)

scopus_only<-anti_join(scopus, crossref, by = join_by(`prism:doi` == doi_no_slash))
crossref_only<-anti_join(crossref, scopus, by = join_by(doi_no_slash == `prism:doi`))

view(scopus_only)

no_jcm <- scopus_only %>% 
    filter(str_detect(`prism:doi`, "jcm|JCM", negate = TRUE))

view(no_jcm)
#ok so i guess there's still 62.5K that appear 
#in scopus but not crossref and aren't from JCB
#jcb got SOLD and we're not worried about it 

#and 128K in crossref only and not scopus
#great
#so now i need to ask pat if he wants me to scrape those and get data from them 
