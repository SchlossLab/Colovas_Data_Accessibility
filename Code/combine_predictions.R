#!/usr/bin/env Rscript
# combine_predictions.R
#
#
#
# library statements
library(tidyverse)

#local work first, then snakemake work
file_list <- list.files("Data/predicted", ".csv", full.names = TRUE)
head(file_list)

read_csv(file_list[3000])

# something like this will work , not totally sure about line 16
predictions <-tibble(file = NULL, da = NULL, nsd = NULL)
for(file in file_list){
    predictions <-bind_rows(predictions, 
    read_csv(file, cols = col_type(.default = col_character())))
}