#look at how many records we found
#
#library statements
library(tidyverse)

file_list <-list.files("Data/scopus", full.names = TRUE)

#total scopus records 111,493 ~76% of 146,645 crossref
all_scopus<- read_csv(file_list)

write_csv(all_scopus, file = "Data/scopus/all_scopus_citations.csv.gz")
