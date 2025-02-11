#!/usr/bin/env Rscript
#data acessibility prelim figures work 
#
#
#
#library statements
library(tidyverse)

#import data 

papers_dir <- "Data/crossref"
csv_files <- list.files(papers_dir, "*.csv", full.names = TRUE) 

all_metadata <- read_csv(csv_files)

write_csv(keep_track, file = "Data/final/predictions_with_metadata.csv.gz")

file_1 <-read_csv(csv_files[1])

file_2<-read_csv(csv_files[2])

read_csv(csv_files[3])
