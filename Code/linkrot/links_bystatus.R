#!/usr/bin/env Rscript
#linkrot figure generator for number of links by status
#
#
#library statements
library(tidyverse)

# load data from snakemake input
# {input.rscript} {input.all_links} {output.all_filename} {output.unique_filename}
input <- commandArgs(trailingOnly = TRUE)
alllinks <- input[1]
alllinks <- read_csv(alllinks)
all_output <- input[2]
unique_output <- input[3]

#non-snakemake implementation
#alllinks <- read_csv("Data/linkrot/groundtruth_alllinks.csv.gz")
#metadatalinks <- read_csv("Data/linkrot/groundtruth_links_metadata.csv.gz")
#all_output <- "Figures/linkrot/groundtruth/alllinks_bystatus.png"
#unique_output <- "Figures/linkrot/groundtruth/uniquelinks_bystatus.png"

#group links by link_status
all_status_tally <- alllinks %>%
                    group_by(link_status) %>% 
                    tally()
unique_status_tally <- unique(alllinks) %>% 
                      group_by(link_status) %>%
                      tally()
all_sum <- as.numeric(sum(all_status_tally$n)) 
unique_sum <- as.numeric(sum(unique_status_tally$n))

#plot number of links with each status 
#20240614 - need to update for unique and non-unique
AllLinksByStatus <- 
  ggplot(
    data = alllinks, 
    mapping = aes(x = factor(link_status), fill = link_status)) + 
  geom_bar() +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = 1.2, color = "white", size = 3) +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Links", 
        x = "Link Status",
        title = stringr::str_glue("Total Number of External User-Added Links by Status (N={all_sum})")) 
AllLinksByStatus

ggsave(AllLinksByStatus, filename = all_output)

UniqueLinksByStatus <- 
  ggplot(
    data = unique(alllinks), 
    mapping = aes(x = factor(link_status), fill = link_status))  + 
  geom_bar() +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = 1.2, color = "white", size = 3) +
  theme(axis.text.x = element_text(angle = 75, vjust = 1, hjust=1)) +
  labs( y = "Number of Links", 
        x = "Link Status",
        title = stringr::str_glue("Unique Number of External User-Added Links by Status (N={unique_sum})"))
UniqueLinksByStatus

ggsave(UniqueLinksByStatus, filename = unique_output)

