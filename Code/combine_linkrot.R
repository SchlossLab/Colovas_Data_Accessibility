#!/usr/bin/env Rscript
# combine_linkrot.R
#
#
#
# library statements
library(tidyverse)

# snakemake input 
#  {input.rscript} {params.p_dir} {output}
input <- commandArgs(trailingOnly = TRUE)
rot_dir <- input[1]
output_file <- input[2]

#local testing
rot_dir <- "Data/linkrot"
local_output<-"Data/final/linkrot_results.csv.gz"


#local work first, then snakemake work
file_list <- list.files(rot_dir, ".csv", full.names = TRUE)
head(file_list)


# something like this will work 
linkrot <-tibble(filenames = NULL, html_tag = NULL, html_filename = NULL, link_address = NULL, 
                link_text = NULL, link_status = NULL, hostname = NULL, domain = NULL, 
                website_type = NULL, binary_status = NULL, is_alive = NULL) 
                

for(file in file_list){
    # new_file <- read_csv(file, col_names = TRUE, col_types = "cccccccccc") 
    # str(new_file)
    linkrot <- bind_rows(linkrot, 
    read_csv(file, col_names = TRUE, col_types = "cccccccccc"))
}


write_csv(linkrot, file = output_file)