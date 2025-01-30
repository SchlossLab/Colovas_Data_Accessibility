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


both_only_scopus<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi_no_slash))
both_only_crossref<-inner_join(crossref, scopus, by = join_by(doi_no_slash == `prism:doi`))
scopus_only<-anti_join(scopus, crossref, by = join_by(`prism:doi` == doi_no_slash))
crossref_only<-anti_join(crossref, scopus, by = join_by(doi_no_slash == `prism:doi`))

view(scopus_only)

#20250130 - all of these from scopus only are 
#valid records and appear in pubmed
# crossref only 128K 
# scopus only 93K
# both 18K
# why can't i get the pubyear or date from scopus idk 