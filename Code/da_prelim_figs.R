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
for(i in 1:12) {
    csv_file <- read_csv(csv_files[i])
    #this does it for the current journal to join with all_papers
    all_papers <- left_join(csv_file, joined_predictions) %>%
        mutate_if(is.double, as.character, .vars = "issue") %>%
        mutate_if(lubridate::is.Date, as.character, .vars = "created")
    keep_track<-bind_rows(keep_track, all_papers)
   
}

# 20250107 - keep_track contains all metadata and all predictions and filenames

#now we can start doing the fun graphing part

# make column for date published (issued) 
metadata <- keep_track %>% 
    mutate(year.published = str_sub(issued, start = 1, end = 4))
metadata %>% count(year.published)


#let's graph nsd over time 
#this doesn't work but honestly what does in my life let's be real 

ggplot(data = metadata, 
    mapping = aes(x = nsd, .by = year.published)) + 
    geom_bar(stat = "count")
