#!/usr/bin/env Rscript
#linkrot figure generator for number of links by status
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.metadata_links} {output.filename}
input <- commandArgs(trailingOnly = TRUE)
metadatalinks <- input[1]
output <- input[2]

#non-snakemake implementation
alllinks <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz")
metadatalinks <- read_csv("Data/linkrot/groundtruth_links_metadata.csv.gz")
#output <- "Figures/linkrot/groundtruth/LinksByJournal.png"

#group links by link_status
all_status_tally <- alllinks %>% group_by(link_status) %>% tally()
unique_status_tally <- unique(alllinks) %>% group_by(link_status) %>% tally()
all_sum <- as.numeric(sum(all_status_tally$n)) 
unique_sum <- as.numeric(sum(unique_status_tally$n))

#plot number of links with each status 
#20240614 - need to update for unique and non-unique
LinksByStatus <- 
  ggplot(
    data = groundtruth_links, 
    mapping = aes(x = factor(link_status)) ) + 
  geom_bar() +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = 1.2, color = "white", size = 3) +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Links", 
        x = "Link Status",
        title = "Number of External User-Added  
        Links by Status (N=270)") 
LinksByStatus

ggsave(LinksByStatus, filename = "Figures/LinksByStatus.png")