#see if they have the same citations or not
#
#
#library
library(tidyverse)

#load files
scopus <-read_csv("Data/scopus/all_scopus_citations.csv.gz")

crossref <-read_csv("Data/papers/all_papers.csv.gz") 

ncbi <-read_csv("Data/ncbi/ncbi_all_papers.csv.gz")

crossref <-
    crossref %>% 
        mutate(doi_no_slash = str_replace(doi, "_", "/"))
head(scopus)
head(crossref)
colnames(ncbi)




unique(ncbi)
ncbi <-ncbi %>%
filter(!is.na(doi))

dupes<- which(duplicated(ncbi$doi))
dupe_table <- rbind(ncbi[dupes,])
ncbi <-anti_join(ncbi, dupe_table)

scopus <-
scopus %>%
filter(!is.na(`prism:doi`))

crossref %>%
filter(is.na(`doi_no_slash`))

unique(scopus)
unique(crossref)

all_three_scn<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi_no_slash)) %>%
    inner_join(., ncbi, by = join_by(`prism:doi` == doi))

# all_three_nsc <-inner_join(ncbi, scopus, by = join_by(doi == `prism:doi`), relationship = "many-to-many") %>%
#     inner_join(., crossref, by = join_by(doi == doi_no_slash))

scopus_and_crossref<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi_no_slash)) %>%
    anti_join(., all_three_scn)

# crossref_and_scopus<-inner_join(crossref, scopus, by = join_by(doi_no_slash == `prism:doi`)) %>%
#     anti_join(., all_three, by = join_by(doi_no_slash == `prism:doi`))

scopus_and_ncbi<-inner_join(scopus, ncbi, by = join_by(`prism:doi` == doi)) %>%
    anti_join(., all_three)


crossref_and_ncbi<-inner_join(crossref, ncbi, by = join_by(doi_no_slash == doi)) %>%
    anti_join(., all_three, by = join_by(doi_no_slash == `prism:doi`))


ncbi_crossref <-inner_join(crossref, ncbi, by = join_by(doi_no_slash == doi)) %>%
    anti_join(., all_three, by = join_by(doi_no_slash == `prism:doi`))




scopus_only<-anti_join(scopus, crossref, by = join_by(`prism:doi` == doi_no_slash)) %>%
   anti_join(., ncbi, by = join_by(`prism:doi` == doi))

crossref_only<-anti_join(crossref, scopus, by = join_by(doi_no_slash == `prism:doi`)) %>%
   anti_join(., ncbi, by = join_by(doi_no_slash == doi))

ncbi_only <- anti_join(ncbi, scopus, by = join_by(doi == `prism:doi`)) %>%
   anti_join(., crossref, by = join_by(doi == doi_no_slash))

ncbi
crossref
scopus

view(rbind(ncbi[127041,], ncbi[127081,],ncbi[127166,]))


