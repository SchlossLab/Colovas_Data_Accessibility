#see if they have the same citations or not
#
#
#library
library(tidyverse)

#load files
scopus <-read_csv("Data/scopus/all_scopus_citations.csv.gz")

crossref <-read_csv("Data/crossref/crossref_all_papers.csv.gz")

ncbi <-read_csv("Data/ncbi/ncbi_all_papers.csv.gz")


head(crossref$doi)



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
filter(is.na(doi))

unique(scopus)
unique(crossref)

ncbi$doi <- tolower(ncbi$doi)
scopus$`prism:doi` <-tolower(scopus$`prism:doi`)
crossref$doi<-tolower(crossref$doi)

all_three<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
    inner_join(., ncbi, by = join_by(`prism:doi` == doi))


scopus_and_crossref<-inner_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
    anti_join(., all_three)



scopus_and_ncbi<-inner_join(scopus, ncbi, by = join_by(`prism:doi` == doi)) %>%
    anti_join(., all_three)


crossref_and_ncbi<-inner_join(crossref, ncbi, by = join_by(doi == doi)) %>%
    anti_join(., all_three, by = join_by(doi == `prism:doi`))


ncbi_crossref <-inner_join(crossref, ncbi, by = join_by(doi == doi)) %>%
    anti_join(., all_three, by = join_by(doi == `prism:doi`))



scopus_only<-anti_join(scopus, crossref, by = join_by(`prism:doi` == doi)) %>%
   anti_join(., ncbi, by = join_by(`prism:doi` == doi))

crossref_only<-anti_join(crossref, scopus, by = join_by(doi == `prism:doi`)) %>%
   anti_join(., ncbi, by = join_by(doi == doi))

ncbi_only <- anti_join(ncbi, scopus, by = join_by(doi == `prism:doi`)) %>%
   anti_join(., crossref, by = join_by(doi == doi))

ncbi
crossref
scopus

grep("retracted", ncbi$title, value = TRUE, ignore.case = TRUE) #9
grep("withdrawn", ncbi$title, value = TRUE, ignore.case = TRUE) #7

grep("retracted", crossref$title, value = TRUE, ignore.case = TRUE) #6
grep("withdrawn", crossref$title, value = TRUE, ignore.case = TRUE) #0
