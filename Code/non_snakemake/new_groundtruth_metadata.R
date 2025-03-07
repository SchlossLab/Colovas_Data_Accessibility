#get new groundtruth metadata from various journals.. 
#hoping that it's all in crossref bc that's the easiest
#20250220
#
#
#library 
library(tidyverse)

#file import
gt_dois <-read_csv("Data/new_groundtruth_dois.csv.gz") %>%
    mutate(doi_slash = str_replace(doi, "_", "/")) %>%
    rename(scrape_url = url)

#get metadata from crossref
crossref <- read_csv("Data/crossref/crossref_all_papers.csv.gz")

#combine gt dois and metadata - there's a dupicate so n = 655
new_metadata<-inner_join(gt_dois, crossref, by = join_by(doi_slash == doi)) %>%
    rename(doi_underscore = doi)


#save new metadat 
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
