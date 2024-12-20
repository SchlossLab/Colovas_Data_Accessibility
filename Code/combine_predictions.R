#!/usr/bin/env Rscript
# combine_predictions.R
#
#
#
# library statements
library(tidyverse)

# snakemake input 
#  {input.rscript} {params.p_dir} {output}
input <- commandArgs(trailingOnly = TRUE)
p_dir <- input[1]
output_file <- input[2]

#local testing
# p_dir <- "Data/predicted"
# local_output<-"Data/final/predicted_results.csv.gz"


#local work first, then snakemake work
file_list <- list.files(p_dir, ".csv", full.names = TRUE)
head(file_list)


# something like this will work , not totally sure about line 16
predictions <-tibble(file = NULL, da = NULL, nsd = NULL)
for(file in file_list){
    predictions <-bind_rows(predictions, 
    read_csv(file, col_names = TRUE, col_types = "c"))
}
#1007 > 

write_csv(predictions, file = output_file)