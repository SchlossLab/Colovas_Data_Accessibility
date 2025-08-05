#!/usr/bin/env Rscript
#create metadata from all dois list with predictions
#
#
#library
library(tidyverse)


#import data 

#total predicted files n = 149,064
predicted_files <-read_csv("Data/final/predicted_results.csv.gz")
head(predicted_files)
#6714 predicted genome announcements 
# predicted_files %>% 
#   filter(str_detect(file, "genome")) %>% 
#   view()

#lookup table n = 156038
lookup_table <-read_csv("Data/all_dois_lookup_table.csv.gz")
head(lookup_table)

# lookup_table %>% 
#   filter(str_detect(paper, "genome"))




#join predicted files with lookup table n = 157037
#this means there are duplicates 
joined_predictions <- inner_join(predicted_files, lookup_table, by = join_by("file" == "html_filename"))
head(joined_predictions)

# 
#there are n = 1316 duplicates, mra duplications removed somehow 
dupes<-which(duplicated(joined_predictions$doi_no_underscore))
length(dupes)
# joined_predictions[dupes,] %>% view()

#removed dupes n = 154721
remove_doi_dupes<-joined_predictions[-dupes,]

# remove_doi_dupes %>%
#   filter(container.title == "Microbiology Resource Announcements"| container.title == "Genome Announcements")  %>%
#   view()


#get metadata from crossref and see how many are in crossref n = 147,325
crossref <- read_csv("Data/crossref/crossref_all_papers.csv.gz") %>%
  mutate(doi = tolower(doi))


#i think anything missing should be in ncbi
ncbi <-read_csv("Data/ncbi/ncbi_all_papers.csv.gz") %>%
  mutate(doi = tolower(doi))
wos <-read_csv("Data/wos/wos_all_papers.csv.gz") %>%
  mutate(doi = tolower(doi))
scopus <-read_csv("Data/scopus/all_scopus_citations.csv.gz") %>%
  mutate(`prism:doi` = tolower(`prism:doi`))

#join with crossref metadata n = 146398 (1609 missing)
metadata_crossref<-inner_join(remove_doi_dupes, crossref, by = join_by(doi_no_underscore == doi, container.title))

# metadata_crossref %>%
#   filter(container.title == "Microbiology Resource Announcements"| container.title == "Genome Announcements")  %>%
#   view()


#7438 missing from crossref
missing_from_crossref<-anti_join(remove_doi_dupes, crossref, by = join_by(doi_no_underscore == doi, container.title))

#how many of the ones missing from crossref have no predictions
#of 1609 missing from crossref, 1190 have predictions 
# missing_cross_predictions<-
# missing_from_crossref %>%
#   filter(!is.na(da) & !is.na(nsd))

#1036 of missing crossref with predictions found in ncbi 
metadata_ncbi<-inner_join(missing_from_crossref, ncbi, by = join_by(doi_no_underscore == doi))
#174 still missing/1190
missing_cross_ncbi<-anti_join(missing_from_crossref, ncbi, by = join_by(doi_no_underscore == doi))


#8 of missing crossref/ncbi found in wos 
metadata_wos <-inner_join(missing_cross_ncbi, wos, by = join_by(doi_no_underscore == doi))
#166 still missing metadata
missing_cr_ncbi_wos <-anti_join(missing_cross_ncbi, wos, by = join_by(doi_no_underscore == doi))

#166 of missing crossref/ncbi/wos found in scopus
metadata_scopus <-inner_join(missing_cr_ncbi_wos, scopus, by = join_by(doi_no_underscore == `prism:doi`))
# 3 have no found metadata? 
missing_all <-anti_join(missing_cr_ncbi_wos, scopus, by = join_by(doi_no_underscore == `prism:doi`))


#need to combine these metadatas n = 148,006

all_metadata <-full_join(metadata_crossref, metadata_ncbi) %>%
  full_join(., metadata_wos) %>% 
  full_join(., metadata_scopus)

write_csv(all_metadata, file = "Data/final/predictions_with_metadata.csv.gz")
