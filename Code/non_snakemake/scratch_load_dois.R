#scratch_load_dois.R
#
#
library(tidyverse)

all_papers<-read_csv("Data/papers/all_papers.csv.gz")

head(all_papers)

lookup_table <-read_csv("Data/papers/lookup_table.csv.gz")
head(lookup_table)
