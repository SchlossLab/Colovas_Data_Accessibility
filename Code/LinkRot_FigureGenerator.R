#!/usr/bin/env Rscript
#linkrot figure generator 
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.all_links} {input.metadata_links}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
metadatalinks <- input[2]

#load needed files
groundtruth <- read_csv("Data/groundtruth.csv")
groundtruth_links <- read_csv("Data/linkrot/groundtruth_links.csv")
groundtruth_linkcount <- read_csv("Data/linkrot/groundtruth_linkcount.csv")
gt_all_links_with_metadata <- read_csv("Data/linkrot/gt_all_links_with_metadata.csv")

# #group articles by the journal they were found in
# journal_tally <- groundtruth_linkcount %>% group_by(container.title) %>% tally()


#plot hostame of deadlinks
error_only <- filter(gt_all_links_with_metadata, link_status != 200)

error_only_hostname <- 
  ggplot(
    data = error_only, 
    mapping = aes(y = hostname, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = "Number of External User-Added  
        Links by Hostname and Status (N=29 of 270)", 
        fill = "Link Status") 
error_only_hostname

ggsave(error_only_hostname, filename = "Figures/error_only_hostname.png")


#plot status of "more permanent hostname links" 
long_lasting <- filter(gt_all_links_with_metadata, 
                       grepl("doi|git|figshare|datadryad|zenodo|asm", hostname))

long_lasting_status <- 
  ggplot(
    data = long_lasting, 
    mapping = aes(y = hostname, fill = as.factor(link_status))
  ) + 
  geom_bar(stat = "count") +
  labs( x = "Number of Links", 
        y = "Website Hostname",
        title = "Number of External User-Added  
        Links by Hostname and Status (N=109)", 
        fill = "Link Status") 
long_lasting_status

ggsave(long_lasting_status, filename = "Figures/long_lasting_status.png")
