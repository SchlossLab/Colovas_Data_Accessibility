#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)

#import data 
predicted_files <-read_csv("Data/final/predicted_results.csv.gz")
head(predictions)

lookup_table <-read_csv("Data/papers/lookup_table.csv.gz")
head(lookup_table)

joined_predictions <- full_join(predicted_files, lookup_table, by = join_by("file" == "html_filename")) 
head(joined_predictions)

papers_dir <- "Data/papers"
csv_files <- list.files(papers_dir, "*.csv", full.names = TRUE) 

keep_track<-tibble()
for (i in 1:12) {
    csv_file <- read_csv(csv_files[i])
    all_papers <- full_join(csv_file, joined_predictions)
    keep_track <-rbind(keep_track, all_papers)
}

#all_papers contains all metadata and all predictions and filenames
# just kidding some of the data is missing i think!!! great!!!

#now we can start doing the fun graphing part

view(count(all_papers, created))
colnames(all_papers)
