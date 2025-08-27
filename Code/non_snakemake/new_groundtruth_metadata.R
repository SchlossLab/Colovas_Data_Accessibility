#get new groundtruth metadata from various journals.. 
#hoping that it's all in crossref bc that's the easiest
#20250220
#
#
#library 
library(tidyverse)

#20250430 - redone lines 11-28 

#file import
gt_dois <-read_csv("Data/new_groundtruth_dois.csv.gz") %>%
    mutate(doi_slash = str_replace(doi, "_", "/")) %>%
    rename(scrape_url = url)

#get metadata from crossref
crossref <- read_csv("Data/crossref/crossref_all_papers.csv.gz")

#combine gt dois and metadata - there's a dupicate so n = 902
new_metadata<-inner_join(gt_dois, crossref, by = join_by(doi_slash == doi)) 

dupes <-which(duplicated(new_metadata))

new_metadata <-new_metadata[-dupes,]

#save new metadata
write_csv(new_metadata, file = "Data/new_groundtruth_metadata.csv.gz")


#20250307 - apparently this table has more duplicates than i knew about 
#and i am deeply annoyed that i got the same papers multiple times

metadata <- read_csv("Data/new_groundtruth.csv") %>%
    mutate(doi_underscore = str_replace(doi, "\\/", "_"))

which(duplicated(metadata$doi_underscore)) 
metadata$doi_underscore[603]

grep("10.1128_jvi.00529-21", metadata$doi_underscore)

metadata <-metadata[-202,]

which(duplicated(metadata$doi_underscore))

#20250331- where is the code for new_groundtruth_metadata/_dois creation??
gt_dois <-read_csv("Data/new_groundtruth_dois.csv.gz")

#ok this is just doi_underscore and the webscrape url (paper)
groundtruth<-read_csv("Data/new_groundtruth.csv")

new_groundtruth_dois <-
groundtruth %>%
    mutate(doi_underscore = str_replace_all(doi, "/", "_")) %>%
    select(paper, doi_underscore) %>%
    rename(url = paper, doi = doi_underscore)

write_csv(new_groundtruth_dois, file = "Data/new_groundtruth_dois.csv.gz")

#okay now what's in the metadata file
gt_metadata <- read_csv("Data/new_groundtruth_metadata.csv.gz")
groundtruth <- read_csv("Data/new_groundtruth.csv")
 
missing<-which(!(colnames(gt_metadata) %in% colnames(groundtruth)))
#gt_metadata missing 
colnames(gt_metadata)[missing]

missing_2<-which(!(colnames(groundtruth) %in% colnames(gt_metadata)))
colnames(groundtruth)[missing_2]

#i have no idea why this is two files
colnames(groundtruth)
view(groundtruth)


#20250430 - adding genome announcements and extra spot checked data to dois list
spot_check <- read_csv("Data/spot_check/20250424_spot_check.csv")
ga <- read_csv("Data/spot_check/20250429_genome_announcements.csv")

doi_spot_check <- 
spot_check %>%
   select(paper, doi) %>% 
   rename(url = paper)

doi_ga <- 
    ga %>%
    mutate(url = paste0("https://journals.asm.org/doi/", doi), 
    doi = str_replace_all(doi, "/", "_")) %>%
    select(url, doi)



gt_dois <-read_csv("Data/new_groundtruth_dois.csv.gz")

new_gt_dois<-rbind(gt_dois, doi_spot_check, doi_ga)
write_csv(new_gt_dois, file = "Data/new_groundtruth_dois.csv.gz")

#ok this is just doi_underscore and the webscrape url (paper)
groundtruth<-read_csv("Data/new_groundtruth.csv")

#20250827 
# trying to find out who classified all these papers
# and also seeing that new_groundtruth and
# new_groundtruth_metadata have different numbers of papers in them??
# so why is this happening 
# if i have to train these models again i'll scream 