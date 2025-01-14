#get list of dois for pat
library(tidyverse)

predicted <-read_csv("Data/final/predicted_results.csv.gz")
colnames(predicted)

dois<-read_csv("Data/papers/all_papers.csv.gz")
colnames(dois)

dois <- 
    dois %>% 
    mutate(doi = str_replace(doi, "_", "/"))
write_csv(dois, "Data/papers/asm_dois.csv")


lookup_table <-read_csv("Data/papers/lookup_table.csv.gz")
